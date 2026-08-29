import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/models/service_provider.dart';
import '../../core/database/local_database.dart';
import '../mock/mock_providers.dart';
import 'auth_repository.dart';

// Helper to resolve the correct regional database instance
FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

abstract class ProviderRepository {
  Future<List<ServiceProvider>> getProviders();
  Future<ServiceProvider?> getProviderById(String id);
  Future<List<ServiceProvider>> getProvidersByCategory(String category);
  Future<List<ServiceProvider>> getFavoriteProviders();
  Future<void> toggleFavorite(String providerId);
  Future<bool> isFavorite(String providerId);
  Future<void> updateProviderProfile(ServiceProvider provider);
  Future<void> submitVerification(String providerId, String name, String phone, String businessDetails);
  Future<void> syncPendingQueue();
}

class SyncedProviderRepository implements ProviderRepository {
  static const String _keyFavorites = 'meetly_favorites';
  static const String _dbKey = 'providers';

  SyncedProviderRepository();

  @override
  Future<List<ServiceProvider>> getProviders() async {
    // Read from local database
    final localList = await HiveLocalDatabase.instance.getMapList(_dbKey);
    if (localList != null) {
      return localList.map((item) => ServiceProvider.fromJson(item)).toList();
    }
    return List.from(mockProviders);
  }

  @override
  Future<ServiceProvider?> getProviderById(String id) async {
    final list = await getProviders();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(String category) async {
    final list = await getProviders();
    return list.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<List<ServiceProvider>> getFavoriteProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(_keyFavorites) ?? [];
    final list = await getProviders();
    return list.where((p) => favIds.contains(p.id)).toList();
  }

  @override
  Future<void> toggleFavorite(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(_keyFavorites) ?? [];
    if (favIds.contains(providerId)) {
      favIds.remove(providerId);
    } else {
      favIds.add(providerId);
    }
    await prefs.setStringList(_keyFavorites, favIds);
  }

  @override
  Future<bool> isFavorite(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList(_keyFavorites) ?? [];
    return favIds.contains(providerId);
  }

  @override
  Future<void> updateProviderProfile(ServiceProvider provider) async {
    // Proactively try to sync pending queue first
    await syncPendingQueue();

    try {
      final dbRef = _database.ref('providers');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      
      List<ServiceProvider> list = [];
      if (snapshot.exists) {
        final rawVal = snapshot.value;
        List<dynamic> rawList = [];
        if (rawVal is List) {
          rawList = rawVal;
        } else if (rawVal is Map) {
          rawList = rawVal.values.toList();
        }
        list = rawList
            .map((item) => ServiceProvider.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } else {
        list = await getProviders();
      }

      final index = list.indexWhere((p) => p.id == provider.id);
      if (index != -1) {
        list[index] = provider;
      } else {
        list.add(provider);
      }

      final mapList = list.map((p) => p.toJson()).toList();
      await dbRef.set(mapList);
      await HiveLocalDatabase.instance.saveMapList(_dbKey, mapList);
      if (kDebugMode) {
        print("ProviderRepo: Profile successfully updated directly on Firebase RTDB.");
      }
      return;
    } catch (e) {
      if (kDebugMode) {
        print("ProviderRepo: Firebase write failed. Queueing profile update task.");
      }
    }

    // Offline update: Modify locally first
    final currentLocal = await getProviders();
    final index = currentLocal.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      currentLocal[index] = provider;
    } else {
      currentLocal.add(provider);
    }
    await HiveLocalDatabase.instance.saveMapList(_dbKey, currentLocal.map((p) => p.toJson()).toList());

    // Queue operation
    await HiveLocalDatabase.instance.addToQueue('updateProvider', provider.toJson());
  }

  @override
  Future<void> submitVerification(
    String providerId,
    String name,
    String phone,
    String businessDetails,
  ) async {
    final provider = await getProviderById(providerId);
    if (provider != null) {
      final updated = provider.copyWith(
        businessName: businessDetails.isNotEmpty ? businessDetails : provider.businessName,
        phone: phone.isNotEmpty ? phone : provider.phone,
        verificationStatus: 'under_review',
      );
      await updateProviderProfile(updated);
    }
  }

  @override
  Future<void> syncPendingQueue() async {
    final queue = await HiveLocalDatabase.instance.getQueue();
    if (queue.isEmpty) return;

    final List<Map<String, dynamic>> remainingTasks = [];
    bool failed = false;

    for (final task in queue) {
      if (failed) {
        remainingTasks.add(task);
        continue;
      }

      final action = task['action'];
      final payload = task['payload'];

      if (action == 'updateProvider') {
        try {
          final dbRef = _database.ref('providers');
          final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
          
          List<ServiceProvider> list = [];
          if (snapshot.exists) {
            final rawVal = snapshot.value;
            List<dynamic> rawList = [];
            if (rawVal is List) {
              rawList = rawVal;
            } else if (rawVal is Map) {
              rawList = rawVal.values.toList();
            }
            list = rawList
                .map((item) => ServiceProvider.fromJson(Map<String, dynamic>.from(item as Map)))
                .toList();
          } else {
            list = await getProviders();
          }

          final updatedProvider = ServiceProvider.fromJson(payload);
          final index = list.indexWhere((p) => p.id == updatedProvider.id);
          if (index != -1) {
            list[index] = updatedProvider;
          } else {
            list.add(updatedProvider);
          }

          final mapList = list.map((p) => p.toJson()).toList();
          await dbRef.set(mapList);
          await HiveLocalDatabase.instance.saveMapList(_dbKey, mapList);
        } catch (e) {
          if (kDebugMode) {
            print("ProviderRepo: Queue sync failed for task $action: $e. Pausing sync.");
          }
          failed = true;
          remainingTasks.add(task);
        }
      } else {
        remainingTasks.add(task);
      }
    }

    // Save remaining tasks
    final prefs = await SharedPreferences.getInstance();
    if (remainingTasks.isEmpty) {
      await prefs.remove('meetly_sync_queue');
    } else {
      final jsonList = remainingTasks.map((item) => json.encode(item)).toList();
      await prefs.setStringList('meetly_sync_queue', jsonList);
    }
  }
}

// Riverpod Provider
final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return SyncedProviderRepository();
});

// StreamProvider listening directly to Realtime Database /providers node
final providersListProvider = StreamProvider<List<ServiceProvider>>((ref) {
  try {
    return _database.ref('providers').onValue.map((event) {
      final rawVal = event.snapshot.value;
      List<dynamic> rawList = [];
      if (rawVal is List) {
        rawList = rawVal;
      } else if (rawVal is Map) {
        rawList = rawVal.values.toList();
      }

      final list = rawList
          .map((item) => ServiceProvider.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (list.isNotEmpty) {
        // Cache to local SQLite/SharedPreferences asynchronously
        final mapList = list.map((p) => p.toJson()).toList();
        HiveLocalDatabase.instance.saveMapList('providers', mapList);
      }
      return list;
    });
  } catch (e) {
    if (kDebugMode) {
      print("ProviderRepo Stream: Error connecting to Firebase ($e). Falling back to local cache.");
    }
    // Fallback stream from local DB
    return Stream.fromFuture(
      HiveLocalDatabase.instance.getMapList('providers').then((localList) {
        if (localList != null) {
          return localList.map((item) => ServiceProvider.fromJson(item)).toList();
        }
        return List<ServiceProvider>.from(mockProviders);
      })
    );
  }
});

// Single Provider Details Riverpod Provider
final providerDetailsProvider = FutureProvider.family<ServiceProvider?, String>((ref, id) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getProviderById(id);
});

// Category-filtered Providers Riverpod Provider
final categoryProvidersProvider = FutureProvider.family<List<ServiceProvider>, String>((ref, category) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getProvidersByCategory(category);
});

// Favorites Providers List Riverpod Provider
final favoritesListProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getFavoriteProviders();
});

// Get current logged in provider's business profile
final currentProviderProfileProvider = FutureProvider<ServiceProvider?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;
  final repo = ref.watch(providerRepositoryProvider);
  final list = await repo.getProviders();
  try {
    return list.firstWhere((p) => p.userId == user.id);
  } catch (_) {
    return null;
  }
});
