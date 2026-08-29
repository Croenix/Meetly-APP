import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model to represent a single promotion banner
class PromoBanner {
  final String id;
  final String promoSubtitle;
  final String promoTitle;
  final String promoDiscount;
  final String bannerImageUrl;

  PromoBanner({
    required this.id,
    required this.promoSubtitle,
    required this.promoTitle,
    required this.promoDiscount,
    required this.bannerImageUrl,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id']?.toString() ?? '',
      promoSubtitle: json['promoSubtitle']?.toString() ?? '',
      promoTitle: json['promoTitle']?.toString() ?? '',
      promoDiscount: json['promoDiscount']?.toString() ?? '',
      bannerImageUrl: json['bannerImageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promoSubtitle': promoSubtitle,
      'promoTitle': promoTitle,
      'promoDiscount': promoDiscount,
      'bannerImageUrl': bannerImageUrl,
    };
  }
}

// Model to represent dynamic app and promo banner settings (kept for backwards compatibility)
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

// Riverpod StateNotifierProvider to expose reactively synced settings to UI (legacy settings support)
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

// --- NEW REACTIVE LIST PROVIDERS FOR CAROUSEL ---
final appBannersStateProvider = StateNotifierProvider<AppBannersNotifier, AsyncValue<List<PromoBanner>>>((ref) {
  final service = ref.watch(syncServiceProvider);
  return AppBannersNotifier(service);
});

class AppBannersNotifier extends StateNotifier<AsyncValue<List<PromoBanner>>> {
  final SyncService _service;

  AppBannersNotifier(this._service) : super(const AsyncValue.loading()) {
    loadBanners();
  }

  Future<void> loadBanners() async {
    state = const AsyncValue.loading();
    try {
      final banners = await _service.fetchBanners();
      state = AsyncValue.data(banners);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class SyncService {
  static const String _cacheKey = 'meetly_cached_settings';
  static const String _serverUrlCacheKey = 'meetly_cached_server_url';
  static const String _bannersCacheKey = 'meetly_cached_banners';

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

  // Fetch multiple banners - Offline-first Sync Algorithm
  Future<List<PromoBanner>> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final activeServerUrl = await fetchDynamicServerUrl();

    // --- STEP 1: Attempt connection to Node.js local admin server ---
    try {
      if (kDebugMode) {
        print("SyncService: Querying banners from Node.js server at $activeServerUrl/api/banners...");
      }

      final client = HttpClientHelper();
      final responseText = await client.get('$activeServerUrl/api/banners').timeout(const Duration(seconds: 2));

      final List<dynamic> rawList = json.decode(responseText);
      final List<PromoBanner> banners = rawList
          .map((item) => PromoBanner.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      // Cache locally
      await prefs.setString(_bannersCacheKey, responseText);
      if (kDebugMode) {
        print("SyncService: Node.js banners sync successful. Cached locally.");
      }
      return banners;
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Node.js server offline for banners. Switching to Firebase RTDB...");
      }
    }

    // --- STEP 2: Fallback to Firebase Realtime Database backup ---
    try {
      final dbRef = FirebaseDatabase.instance.ref('banners');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));

      if (snapshot.exists) {
        final rawVal = snapshot.value;
        List<dynamic> rawList = [];
        if (rawVal is List) {
          rawList = rawVal;
        } else if (rawVal is Map) {
          rawList = rawVal.values.toList();
        }

        final List<PromoBanner> banners = rawList
            .map((item) => PromoBanner.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        // Cache locally
        await prefs.setString(_bannersCacheKey, json.encode(rawList));
        if (kDebugMode) {
          print("SyncService: Firebase banners sync successful. Cached locally.");
        }
        return banners;
      }
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Firebase RTDB offline/failed for banners ($e).");
      }
    }

    // --- STEP 3: Load cached banners from SharedPreferences ---
    final cachedText = prefs.getString(_bannersCacheKey);
    if (cachedText != null && cachedText.isNotEmpty) {
      try {
        final List<dynamic> rawList = json.decode(cachedText);
        return rawList
            .map((item) => PromoBanner.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } catch (e) {
        if (kDebugMode) {
          print("SyncService: Error parsing cached banners ($e).");
        }
      }
    }

    // --- STEP 4: Default offline banners fallback ---
    return [
      PromoBanner(
        id: 'default_1',
        promoSubtitle: "Save 30% Today!",
        promoTitle: "Exclusive discounts on home services",
        promoDiscount: "30%",
        bannerImageUrl: "",
      )
    ];
  }

  // Primary offline-first fetch sync algorithm (legacy settings support)
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
