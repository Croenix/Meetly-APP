import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model to represent dynamic app and promo banner settings
class AppSyncSettings {
  final String promoSubtitle;
  final String promoTitle;
  final String promoDiscount;
  final String bannerImageUrl;
  final String source; // 'nodejs', 'firebase', 'cache', 'default'

  AppSyncSettings({
    required this.promoSubtitle,
    required this.promoTitle,
    required this.promoDiscount,
    required this.bannerImageUrl,
    required this.source,
  });

  factory AppSyncSettings.defaultOffline() {
    return AppSyncSettings(
      promoSubtitle: "Save 30% Today!",
      promoTitle: "Exclusive discounts on home services",
      promoDiscount: "30%",
      bannerImageUrl: "",
      source: "default",
    );
  }

  factory AppSyncSettings.fromMap(Map<String, dynamic> map, String source) {
    return AppSyncSettings(
      promoSubtitle: map['promoSubtitle'] ?? "Save 30% Today!",
      promoTitle: map['promoTitle'] ?? "Exclusive discounts on home services",
      promoDiscount: map['promoDiscount'] ?? "30%",
      bannerImageUrl: map['bannerImageUrl'] ?? "",
      source: source,
    );
  }
}

// Riverpod Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

// Riverpod StateNotifierProvider to expose reactively synced settings to UI
final appSettingsStateProvider = StateNotifierProvider<AppSettingsNotifier, AsyncValue<AppSyncSettings>>((ref) {
  final service = ref.watch(syncServiceProvider);
  return AppSettingsNotifier(service);
});

class AppSettingsNotifier extends StateNotifier<AsyncValue<AppSyncSettings>> {
  final SyncService _service;

  AppSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _service.fetchSyncSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class SyncService {
  static const String _cacheKey = 'meetly_cached_settings';
  static const String _serverUrlCacheKey = 'meetly_cached_server_url';

  // Getter for standard hardcoded default server URL
  String get defaultServerUrl {
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  // Resolves localhost strings for Android Emulator compatibility
  String _resolveUrl(String url) {
    if (defaultTargetPlatform == TargetPlatform.android && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  // Dynamic URL Fetching System from Firebase Realtime Database
  Future<String> fetchDynamicServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Step 1: Attempt to retrieve from Firebase RTDB path 'server_url'
    try {
      final dbRef = FirebaseDatabase.instance.ref('server_url');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      if (snapshot.exists) {
        final url = snapshot.value.toString();
        await prefs.setString(_serverUrlCacheKey, url);
        if (kDebugMode) {
          print("SyncService: Retrieved dynamic server URL from Firebase RTDB: $url");
        }
        return _resolveUrl(url);
      }
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Firebase server_url fetch failed/offline ($e).");
      }
    }

    // Step 2: Fallback to local SharedPreferences cache
    final cachedUrl = prefs.getString(_serverUrlCacheKey);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      if (kDebugMode) {
        print("SyncService: Using cached server URL: $cachedUrl");
      }
      return _resolveUrl(cachedUrl);
    }

    // Step 3: Fallback to default local server configuration
    final fallbackUrl = defaultServerUrl;
    if (kDebugMode) {
      print("SyncService: Falling back to default URL: $fallbackUrl");
    }
    return fallbackUrl;
  }

  // Primary offline-first fetch sync algorithm
  Future<AppSyncSettings> fetchSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Resolve dynamic server URL first
    final activeServerUrl = await fetchDynamicServerUrl();
    
    // --- STEP 1: Attempt connection to Node.js local admin server ---
    try {
      if (kDebugMode) {
        print("SyncService: Querying primary Node.js server at $activeServerUrl/api/settings...");
      }
      
      final client = HttpClientHelper();
      final responseText = await client.get('$activeServerUrl/api/settings').timeout(const Duration(seconds: 2));
      
      final Map<String, dynamic> data = json.decode(responseText);
      
      // Save successfully to local SharedPreferences cache
      await prefs.setString(_cacheKey, responseText);
      if (kDebugMode) {
        print("SyncService: Node.js sync successful. Cached settings locally.");
      }
      
      return AppSyncSettings.fromMap(data, 'nodejs');
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Node.js server went offline or returned error ($e).");
      }
    }

    // --- STEP 2: Fallback to Firebase Realtime Database backup ---
    try {
      if (kDebugMode) {
        print("SyncService: Fetching backup settings from Firebase Realtime Database...");
      }
      
      final dbRef = FirebaseDatabase.instance.ref('settings');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      
      if (snapshot.exists) {
        final Map<Object?, Object?> rawVal = snapshot.value as Map<Object?, Object?>;
        // Convert to Map<String, dynamic>
        final Map<String, dynamic> data = {};
        rawVal.forEach((key, value) {
          data[key.toString()] = value;
        });
        
        // Cache to local SharedPreferences
        await prefs.setString(_cacheKey, json.encode(data));
        if (kDebugMode) {
          print("SyncService: Firebase sync successful. Cached backup settings locally.");
        }
        
        return AppSyncSettings.fromMap(data, 'firebase');
      } else {
        if (kDebugMode) {
          print("SyncService: Firebase database is empty/settings path not found.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Firebase Realtime Database went offline or returned error ($e).");
      }
    }

    // --- STEP 3: Load cached settings from SharedPreferences ---
    final cachedDataText = prefs.getString(_cacheKey);
    if (cachedDataText != null) {
      try {
        final Map<String, dynamic> data = json.decode(cachedDataText);
        if (kDebugMode) {
          print("SyncService: Complete offline recovery. Loaded settings from SharedPreferences cache.");
        }
        return AppSyncSettings.fromMap(data, 'cache');
      } catch (e) {
        if (kDebugMode) {
          print("SyncService: Failed to parse cached settings ($e).");
        }
      }
    }

    // --- STEP 4: Final offline assets fallback ---
    if (kDebugMode) {
      print("SyncService: No cached settings found. Falling back to default offline configuration.");
    }
    return AppSyncSettings.defaultOffline();
  }
}

// Simple Helper to handle standard HTTP GET client request using dart:io
class HttpClientHelper {
  Future<String> get(String urlString) async {
    final uri = Uri.parse(urlString);
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        return responseBody;
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
    } finally {
      httpClient.close();
    }
  }
}
