import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/local_database.dart';

// Helper to resolve Firebase RTDB
FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

// Model for Real-time System Analytics
class AdminTelemetryData {
  final int activeConnections;
  final int totalUsers;
  final int customerCount;
  final int providerCount;
  final int totalBookings;
  final Map<String, int> bookingMetrics;
  final double totalRevenue;
  final double avgTicketSize;
  final String currency;
  final String timestamp;
  final bool isConnected;

  AdminTelemetryData({
    required this.activeConnections,
    required this.totalUsers,
    required this.customerCount,
    required this.providerCount,
    required this.totalBookings,
    required this.bookingMetrics,
    required this.totalRevenue,
    required this.avgTicketSize,
    required this.currency,
    required this.timestamp,
    this.isConnected = true,
  });

  factory AdminTelemetryData.fallbackOffline() {
    return AdminTelemetryData(
      activeConnections: 0,
      totalUsers: 8,
      customerCount: 3,
      providerCount: 4,
      totalBookings: 5,
      bookingMetrics: {
        'pending': 1,
        'confirmed': 1,
        'inProgress': 1,
        'completed': 2,
        'cancelled': 0,
      },
      totalRevenue: 2946.0,
      avgTicketSize: 589.0,
      currency: "INR",
      timestamp: DateTime.now().toIso8601String(),
      isConnected: false,
    );
  }

  factory AdminTelemetryData.fromJson(Map<String, dynamic> json, {bool isConnected = true}) {
    final bMetrics = json['bookingMetrics'] as Map<String, dynamic>? ?? {};
    final rMetrics = json['revenueMetrics'] as Map<String, dynamic>? ?? {};

    return AdminTelemetryData(
      activeConnections: (json['activeConnections'] as num?)?.toInt() ?? 0,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      customerCount: (json['customerCount'] as num?)?.toInt() ?? 0,
      providerCount: (json['providerCount'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      bookingMetrics: {
        'pending': (bMetrics['pending'] as num?)?.toInt() ?? 0,
        'confirmed': (bMetrics['confirmed'] as num?)?.toInt() ?? 0,
        'inProgress': (bMetrics['inProgress'] as num?)?.toInt() ?? 0,
        'completed': (bMetrics['completed'] as num?)?.toInt() ?? 0,
        'cancelled': (bMetrics['cancelled'] as num?)?.toInt() ?? 0,
      },
      totalRevenue: (rMetrics['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      avgTicketSize: (rMetrics['avgTicketSize'] as num?)?.toDouble() ?? 0.0,
      currency: rMetrics['currency']?.toString() ?? "INR",
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      isConnected: isConnected,
    );
  }
}

// Global Provider for RealtimeWebSocketService
final realtimeWebSocketServiceProvider = Provider<RealtimeWebSocketService>((ref) {
  final service = RealtimeWebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider exposing Stream of Admin Telemetry
final adminTelemetryStreamProvider = StreamProvider<AdminTelemetryData>((ref) {
  final service = ref.watch(realtimeWebSocketServiceProvider);
  return service.telemetryStream;
});

class RealtimeWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<AdminTelemetryData> _telemetryController =
      StreamController<AdminTelemetryData>.broadcast();

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnected = false;
  String? _resolvedWsUrl;

  Stream<AdminTelemetryData> get telemetryStream => _telemetryController.stream;
  bool get isConnected => _isConnected;
  String? get currentWsUrl => _resolvedWsUrl;

  RealtimeWebSocketService() {
    _initConnection();
  }

  Future<void> _initConnection() async {
    final wsUrl = await _resolveDynamicWsUrl();
    _resolvedWsUrl = wsUrl;

    if (wsUrl == null || wsUrl.isEmpty) {
      if (kDebugMode) {
        print("RealtimeWS: Could not resolve dynamic WS URL. Using fallback offline state.");
      }
      _telemetryController.add(AdminTelemetryData.fallbackOffline());
      _scheduleReconnect();
      return;
    }

    try {
      if (kDebugMode) {
        print("RealtimeWS: Connecting direct WebSocket to $wsUrl...");
      }
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
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

      // Start ping heartbeat
      _startHeartbeat();

      // Flush queued offline items upon connection
      flushOfflineQueue();

    } catch (e) {
      if (kDebugMode) {
        print("RealtimeWS: Failed to connect WebSocket: $e");
      }
      _handleDisconnect();
    }
  }

  // Resolves the dynamic server IP / WebSocket URL from Firebase Realtime Database
  Future<String?> _resolveDynamicWsUrl() async {
    try {
      // 1. Try Firebase RTDB /ws_url node first
      final dbRef = _database.ref('ws_url');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      if (snapshot.exists && snapshot.value != null) {
        final val = snapshot.value.toString();
        if (val.isNotEmpty) {
          if (kDebugMode) {
            print("RealtimeWS: Dynamic WS URL resolved from Firebase RTDB: $val");
          }
          return val;
        }
      }

      // 2. Fallback to /server_url node converted to ws://
      final serverRef = _database.ref('server_url');
      final serverSnap = await serverRef.get().timeout(const Duration(seconds: 3));
      if (serverSnap.exists && serverSnap.value != null) {
        String httpUrl = serverSnap.value.toString();
        String wsUrl = httpUrl.replaceAll('http://', 'ws://').replaceAll('https://', 'wss://');
        if (kDebugMode) {
          print("RealtimeWS: Dynamic WS URL converted from server_url: $wsUrl");
        }
        return wsUrl;
      }
    } catch (e) {
      if (kDebugMode) {
        print("RealtimeWS: Could not fetch dynamic IP from Firebase: $e");
      }
    }

    // Default localhost fallback for emulator/desktop
    return 'ws://localhost:5000';
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawMessage.toString());
      final type = data['type']?.toString();

      if (type == 'ADMIN_TELEMETRY' && data['data'] != null) {
        final telemetry = AdminTelemetryData.fromJson(
          Map<String, dynamic>.from(data['data']),
          isConnected: true,
        );
        _telemetryController.add(telemetry);
        
        // Cache latest telemetry locally for offline access
        HiveLocalDatabase.instance.saveString('latest_telemetry', rawMessage.toString());
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
    
    // Read cached telemetry or push offline fallback
    final cached = await HiveLocalDatabase.instance.getString('latest_telemetry');
    if (cached != null && cached.isNotEmpty) {
      try {
        final parsed = jsonDecode(cached);
        if (parsed['data'] != null) {
          _telemetryController.add(AdminTelemetryData.fromJson(
            Map<String, dynamic>.from(parsed['data']),
            isConnected: false,
          ));
        } else {
          _telemetryController.add(AdminTelemetryData.fallbackOffline());
        }
      } catch (_) {
        _telemetryController.add(AdminTelemetryData.fallbackOffline());
      }
    } else {
      _telemetryController.add(AdminTelemetryData.fallbackOffline());
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
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _telemetryController.close();
  }
}
