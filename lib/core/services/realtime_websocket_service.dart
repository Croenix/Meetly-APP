import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/device_session_model.dart';
import '../database/local_database.dart';
import 'auth_handshake_service.dart';
import '../config/app_config.dart';

// Backward compatibility typedefs
typedef AdminTelemetryData = SystemTelemetryModel;
typedef DeviceSessionInfo = DeviceSessionModel;

enum ServerConnectionStatus { connected, connecting, disconnected }

// Global Riverpod Provider for RealtimeWebSocketService
final realtimeWebSocketServiceProvider = Provider<RealtimeWebSocketService>((ref) {
  final service = RealtimeWebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

// StreamProvider for System Telemetry
final adminTelemetryStreamProvider = StreamProvider<SystemTelemetryModel>((ref) {
  final service = ref.watch(realtimeWebSocketServiceProvider);
  return service.telemetryStream;
});

// Riverpod Provider for Server Connection Status
final serverConnectionStatusProvider = Provider<ServerConnectionStatus>((ref) {
  final telemetryAsync = ref.watch(adminTelemetryStreamProvider);
  return telemetryAsync.when(
    data: (data) => data.isConnected ? ServerConnectionStatus.connected : ServerConnectionStatus.disconnected,
    loading: () => ServerConnectionStatus.connecting,
    error: (err, stack) => ServerConnectionStatus.disconnected,
  );
});

class RealtimeWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<SystemTelemetryModel> _telemetryController =
      StreamController<SystemTelemetryModel>.broadcast();

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  StreamSubscription? _discoverySubscription;
  bool _isConnected = false;
  String? _resolvedWsUrl;
  String? _resolvedHttpUrl;
  String? _sessionKey;
  
  final String _deviceId = 'dev_${kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch % 10000}';
  final String _userId = 'usr_mobile_client';

  Stream<SystemTelemetryModel> get telemetryStream => _telemetryController.stream;
  bool get isConnected => _isConnected;
  String? get currentWsUrl => _resolvedWsUrl;
  String get deviceId => _deviceId;

  RealtimeWebSocketService() {
    _initConnection();
    _listenToDynamicServiceDiscovery();
  }

  // Listens to Firebase RTDB Discovery Layer for dynamic server IP / URL changes
  void _listenToDynamicServiceDiscovery() {
    try {
      final dbRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref('ws_url');

      _discoverySubscription = dbRef.onValue.listen((event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          final newWsUrl = event.snapshot.value.toString();
          if (newWsUrl.isNotEmpty && newWsUrl != _resolvedWsUrl) {
            if (kDebugMode) {
              print("RealtimeWS: Dynamic Discovery updated URL to $newWsUrl. Terminating stale connection & reconnecting...");
            }
            _reconnectWithUrl(newWsUrl);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("RealtimeWS: Discovery listener error: $e");
      }
    }
  }

  Future<void> _reconnectWithUrl(String wsUrl) async {
    _channel?.sink.close();
    _isConnected = false;
    _resolvedWsUrl = wsUrl;
    await _initConnection();
  }

  Future<void> _initConnection() async {
    final urls = await _resolveDynamicUrls();
    _resolvedHttpUrl = urls['http'];
    _resolvedWsUrl = urls['ws'];

    if (_resolvedHttpUrl == null || _resolvedWsUrl == null) {
      _telemetryController.add(SystemTelemetryModel.fallbackOffline());
      _scheduleReconnect();
      return;
    }

    // Step 1 & 2: REST Handshake & Key Authentication
    final handshakeRes = await AuthHandshakeService.performHandshake(
      serverBaseUrl: _resolvedHttpUrl!,
      userId: _userId,
      deviceId: _deviceId,
    );

    if (!handshakeRes.isSuccess || handshakeRes.sessionKey.isEmpty) {
      if (kDebugMode) {
        print("RealtimeWS: REST Handshake rejected: ${handshakeRes.errorMessage}");
      }
      _telemetryController.add(SystemTelemetryModel.fallbackOffline());
      _scheduleReconnect();
      return;
    }

    _sessionKey = handshakeRes.sessionKey;

    // Step 3: Establish Authenticated Direct WebSocket Connection
    final authenticatedWsUri = '${_resolvedWsUrl!}/ws/live?token=$_sessionKey';
    await _connectToWs(authenticatedWsUri);
  }

  Future<void> _connectToWs(String authenticatedWsUri) async {
    try {
      if (kDebugMode) {
        print("RealtimeWS: Connecting authenticated WebSocket ($authenticatedWsUri)...");
      }
      _channel = WebSocketChannel.connect(Uri.parse(authenticatedWsUri));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          if (kDebugMode) {
            print("RealtimeWS: Connection error: $error");
          }
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) {
            print("RealtimeWS: Connection closed.");
          }
          _handleDisconnect();
        },
      );

      // Start periodic 15s Heartbeat Ping/Pong Protocol
      _startHeartbeat();

      // Transmit client identification over secure channel
      final platformName = kIsWeb ? 'Web Browser' : defaultTargetPlatform.name;
      sendAction('CLIENT_IDENTIFY', {
        'deviceId': _deviceId,
        'userId': _userId,
        'deviceName': kIsWeb ? 'Meetly Web Client' : 'RMX3686 (Realme 10 Pro+ 5G)',
        'platform': platformName,
        'connectedAt': DateTime.now().toIso8601String(),
      });

      // Flush pending offline queue upon connection
      flushOfflineQueue();

    } catch (e) {
      if (kDebugMode) {
        print("RealtimeWS: Failed to connect WebSocket: $e");
      }
      _handleDisconnect();
    }
  }

  String _sanitizeUrlForPlatform(String rawUrl) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return rawUrl
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll(RegExp(r'192\.168\.56\.\d+'), '10.0.2.2');
    }
    return rawUrl;
  }

  // Resolves the dynamic server IP / WebSocket URL from Firebase Realtime Database node (/server_url & /ws_url)
  Future<Map<String, String>> _resolveDynamicUrls() async {
    String httpUrl = AppConfig.baseUrl;
    String wsUrl = AppConfig.wsUrl;

    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
      );

      final httpSnap = await db.ref('server_url').get().timeout(const Duration(seconds: 3));
      if (httpSnap.exists && httpSnap.value != null && httpSnap.value.toString().isNotEmpty) {
        httpUrl = httpSnap.value.toString().trim();
      }

      final wsSnap = await db.ref('ws_url').get().timeout(const Duration(seconds: 3));
      if (wsSnap.exists && wsSnap.value != null && wsSnap.value.toString().isNotEmpty) {
        wsUrl = wsSnap.value.toString().trim();
      } else if (httpUrl.isNotEmpty) {
        wsUrl = httpUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
      }

      // Sanitize URL for target platform (localhost -> 10.0.2.2 on Android)
      httpUrl = _sanitizeUrlForPlatform(httpUrl);
      wsUrl = _sanitizeUrlForPlatform(wsUrl);

      if (kDebugMode) {
        print("RealtimeWS: Dynamic Discovery resolved '/server_url' -> $httpUrl & '/ws_url' -> $wsUrl for platform");
      }
    } catch (e) {
      if (kDebugMode) {
        print("RealtimeWS: Firebase RTDB discovery warning ($e). Operating with local fallback.");
      }
    }

    return {'http': httpUrl, 'ws': wsUrl};
  }

  void _handleMessage(dynamic rawMessage) async {
    try {
      final Map<String, dynamic> data = jsonDecode(rawMessage.toString());

      if (data['type'] == 'ADMIN_TELEMETRY' && data['data'] != null) {
        final telemetry = SystemTelemetryModel.fromJson(
          Map<String, dynamic>.from(data['data']),
          isConnected: true,
        );
        _telemetryController.add(telemetry);
        
        // Cache latest telemetry payload to Hive local storage before UI rendering
        HiveLocalDatabase.instance.saveString('latest_telemetry', rawMessage.toString());
      } else if (data['type'] == 'CONFIG_UPDATE') {
        if (data['banners'] != null && data['banners'] is List) {
          final bannerList = (data['banners'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          await HiveLocalDatabase.instance.saveMapList('banners', bannerList);
        }
        if (data['categories'] != null && data['categories'] is List) {
          final catList = (data['categories'] as List).map((e) => e.toString()).toList();
          await HiveLocalDatabase.instance.saveStringList('categories', catList);
        }
        if (data['settings'] != null && data['settings'] is Map) {
          await HiveLocalDatabase.instance.saveMap('settings', Map<String, dynamic>.from(data['settings']));
        }
        if (data['bookings'] != null && data['bookings'] is List) {
          final bookingList = (data['bookings'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          await HiveLocalDatabase.instance.saveMapList('bookings', bookingList);
        }
        if (kDebugMode) {
          print("RealtimeWS: Received CONFIG_UPDATE broadcast. Successfully reconciled local Hive storage.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("RealtimeWS: Error parsing message: $e");
      }
    }
  }

  Future<void> _handleDisconnect() async {
    _isConnected = false;
    _pingTimer?.cancel();
    
    // Read cached telemetry from Hive for offline fallback
    final cached = await HiveLocalDatabase.instance.getString('latest_telemetry');
    if (cached != null && cached.isNotEmpty) {
      try {
        final parsed = jsonDecode(cached);
        if (parsed['data'] != null) {
          _telemetryController.add(SystemTelemetryModel.fromJson(
            Map<String, dynamic>.from(parsed['data']),
            isConnected: false,
          ));
        } else {
          _telemetryController.add(SystemTelemetryModel.fallbackOffline());
        }
      } catch (_) {
        _telemetryController.add(SystemTelemetryModel.fallbackOffline());
      }
    } else {
      _telemetryController.add(SystemTelemetryModel.fallbackOffline());
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _initConnection();
      }
    });
  }

  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isConnected && _channel != null) {
        sendAction('PING', {});
      }
    });
  }

  // Sends action message over direct WebSocket connection
  void sendAction(String type, Map<String, dynamic> payload) {
    if (_isConnected && _channel != null) {
      try {
        final msg = jsonEncode({
          'type': type,
          ...payload,
        });
        _channel!.sink.add(msg);
      } catch (e) {
        if (kDebugMode) {
          print("RealtimeWS: Error sending action $type: $e");
        }
      }
    }
  }

  // Flushes queued offline actions to server upon connection
  Future<void> flushOfflineQueue() async {
    final queue = await HiveLocalDatabase.instance.getPendingQueue();
    if (queue.isNotEmpty && _isConnected) {
      if (kDebugMode) {
        print("RealtimeWS: Flushing ${queue.length} offline queued items over WebSocket...");
      }
      sendAction('SYNC_QUEUE', {'queue': queue});
      await HiveLocalDatabase.instance.clearQueue();
    }
  }

  void dispose() {
    _discoverySubscription?.cancel();
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _telemetryController.close();
  }
}
