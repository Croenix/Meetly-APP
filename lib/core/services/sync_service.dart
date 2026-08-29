import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Helper to resolve the correct regional database instance
FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

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

// Model to represent dynamic app settings
class AppSyncSettings {
  final String promoSubtitle;
  final String promoTitle;
  final String promoDiscount;
  final String bannerImageUrl;
  final String source; // 'firebase', 'cache', 'default'

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
  StreamSubscription? _subscription;

  AppSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _initRealTimeListener();
  }

  void _initRealTimeListener() {
    // Initial fetch
    _service.fetchSyncSettings().then((settings) {
      if (mounted) {
        state = AsyncValue.data(settings);
      }
    }).catchError((e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    });

    // Real-Time Database listener binding
    try {
      _subscription = _database.ref('settings').onValue.listen((event) {
        if (!event.snapshot.exists) return;
        
        final rawVal = event.snapshot.value as Map<dynamic, dynamic>;
        final converted = <String, dynamic>{};
        rawVal.forEach((key, value) {
          converted[key.toString()] = value;
        });

        final settings = AppSyncSettings.fromMap(converted, 'firebase');
        if (mounted) {
          state = AsyncValue.data(settings);
        }

        // Cache locally in SharedPreferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString(SyncService._cacheKey, json.encode(converted));
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Failed to bind settings real-time stream listener: $e");
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// --- NEW REACTIVE LIST PROVIDERS FOR CAROUSEL ---
final appBannersStateProvider = StateNotifierProvider<AppBannersNotifier, AsyncValue<List<PromoBanner>>>((ref) {
  final service = ref.watch(syncServiceProvider);
  return AppBannersNotifier(service);
});

class AppBannersNotifier extends StateNotifier<AsyncValue<List<PromoBanner>>> {
  final SyncService _service;
  StreamSubscription? _subscription;

  AppBannersNotifier(this._service) : super(const AsyncValue.loading()) {
    _initRealTimeListener();
  }

  void _initRealTimeListener() {
    // Initial load from cache or RTDB
    _service.fetchBanners().then((banners) {
      if (mounted) {
        state = AsyncValue.data(banners);
      }
    }).catchError((e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    });

    // Setup Realtime Database Stream Listener for Banners
    try {
      _subscription = _database.ref('banners').onValue.listen((event) {
        if (!event.snapshot.exists) return;
        
        final rawVal = event.snapshot.value;
        List<dynamic> rawList = [];
        if (rawVal is List) {
          rawList = rawVal;
        } else if (rawVal is Map) {
          rawList = rawVal.values.toList();
        }

        final banners = rawList
            .map((item) => PromoBanner.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        if (mounted) {
          state = AsyncValue.data(banners);
        }

        // Cache it locally in SharedPreferences asynchronously
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString(SyncService._bannersCacheKey, json.encode(rawList));
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Failed to bind banners real-time stream listener: $e");
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class SyncService {
  static const String _cacheKey = 'meetly_cached_settings';
  static const String _bannersCacheKey = 'meetly_cached_banners';

  // Fetch multiple banners - Offline-first Sync Algorithm directly via Firebase RTDB
  Future<List<PromoBanner>> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();

    // --- STEP 1: Fetch directly from Firebase Realtime Database ---
    try {
      if (kDebugMode) {
        print("SyncService: Fetching banners from Firebase Realtime Database...");
      }
      final dbRef = _database.ref('banners');
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
        return banners;
      }
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Firebase RTDB offline/failed for banners ($e). Loading from cache...");
      }
    }

    // --- STEP 2: Load cached banners from SharedPreferences ---
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

    // --- STEP 3: Default offline banners fallback ---
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

  // Primary offline-first fetch sync algorithm directly via Firebase RTDB
  Future<AppSyncSettings> fetchSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // --- STEP 1: Fetch directly from Firebase Realtime Database ---
    try {
      if (kDebugMode) {
        print("SyncService: Fetching settings from Firebase Realtime Database...");
      }
      final dbRef = _database.ref('settings');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      
      if (snapshot.exists) {
        final Map<Object?, Object?> rawVal = snapshot.value as Map<Object?, Object?>;
        final Map<String, dynamic> data = {};
        rawVal.forEach((key, value) {
          data[key.toString()] = value;
        });
        
        await prefs.setString(_cacheKey, json.encode(data));
        return AppSyncSettings.fromMap(data, 'firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print("SyncService: Firebase Realtime Database offline or returned error ($e).");
      }
    }

    // --- STEP 2: Load cached settings from SharedPreferences ---
    final cachedDataText = prefs.getString(_cacheKey);
    if (cachedDataText != null) {
      try {
        final Map<String, dynamic> data = json.decode(cachedDataText);
        return AppSyncSettings.fromMap(data, 'cache');
      } catch (e) {
        if (kDebugMode) {
          print("SyncService: Failed to parse cached settings ($e).");
        }
      }
    }

    return AppSyncSettings.defaultOffline();
  }
}
