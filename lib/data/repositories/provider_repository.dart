import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/service_provider.dart';
import '../../core/services/sync_service.dart';
import '../../core/database/local_database.dart';
import '../mock/mock_providers.dart';
import 'auth_repository.dart';

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
  final SyncService _syncService;

  SyncedProviderRepository(this._syncService);

  @override
  Future<List<ServiceProvider>> getProviders() async {
    final serverUrl = await _syncService.fetchDynamicServerUrl();
    final client = HttpClientHelper();

    // Sync pending offline operations before querying fresh state
    await syncPendingQueue();

    try {
      if (kDebugMode) {
        print("ProviderRepo: Querying providers from server: $serverUrl/api/providers");
      }
      final responseText = await client.get('$serverUrl/api/providers').timeout(const Duration(seconds: 2));
      final List<dynamic> rawList = json.decode(responseText);
      final List<ServiceProvider> providers = rawList
          .map((item) => ServiceProvider.fromJson(item as Map<String, dynamic>))
          .toList();

      // Cache locally in local document store
      final mapList = providers.map((p) => p.toJson()).toList();
      await HiveLocalDatabase.instance.saveMapList(_dbKey, mapList);
      
      return providers;
    } catch (e) {
      if (kDebugMode) {
        print("ProviderRepo: Server offline ($e). Loading from local database...");
      }
    }

    // Fallback: Read from local storage
    final localList = await HiveLocalDatabase.instance.getMapList(_dbKey);
    if (localList != null) {
      return localList.map((item) => ServiceProvider.fromJson(item)).toList();
    }

    // Secondary Fallback: Seeded mock providers
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
    final serverUrl = await _syncService.fetchDynamicServerUrl();

    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('$serverUrl/api/providers');
      final request = await httpClient.postUrl(uri);
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(provider.toJson())));
      
      final response = await request.close();
      httpClient.close();
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("ProviderRepo: Profile successfully synced to Node.js backend.");
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print("ProviderRepo: Server offline. Queueing profile update task.");
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

    final serverUrl = await _syncService.fetchDynamicServerUrl();
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
          final httpClient = HttpClient();
          final uri = Uri.parse('$serverUrl/api/providers');
          final request = await httpClient.postUrl(uri);
          request.headers.set('content-type', 'application/json');
          request.add(utf8.encode(json.encode(payload)));
          
          final response = await request.close();
          httpClient.close();
          if (response.statusCode != 200) throw Exception("Failed");
        } catch (e) {
          if (kDebugMode) {
            print("ProviderRepo: Queue sync failed for task $action: $e. Pausing sync.");
          }
          failed = true;
          remainingTasks.add(task);
        }
      } else {
        // Carry forward non-provider tasks in the shared queue
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
  final syncService = ref.watch(syncServiceProvider);
  return SyncedProviderRepository(syncService);
});

// Providers List Riverpod Provider
final providersListProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  return repo.getProviders();
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
