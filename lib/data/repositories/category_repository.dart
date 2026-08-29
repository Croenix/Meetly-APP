import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/sync_service.dart';
import '../../core/database/local_database.dart';

abstract class CategoryRepository {
  Future<List<String>> getCategories();
  Future<void> addCategory(String category);
  Future<void> deleteCategory(String category);
  Future<void> syncPendingQueue();
}

class SyncedCategoryRepository implements CategoryRepository {
  final SyncService _syncService;
  static const String _dbKey = 'categories';

  final List<String> _defaultCategories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Appliance',
    'Painting',
    'Carpentry',
    'Pest Control',
    'Salon'
  ];

  SyncedCategoryRepository(this._syncService);

  @override
  Future<List<String>> getCategories() async {
    final serverUrl = await _syncService.fetchDynamicServerUrl();
    final client = HttpClientHelper();
    
    // Proactively attempt to sync any pending queue operations first
    await syncPendingQueue();

    try {
      if (kDebugMode) {
        print("CategoryRepo: Querying categories from server: $serverUrl/api/categories");
      }
      
      final responseText = await client.get('$serverUrl/api/categories').timeout(const Duration(seconds: 2));
      final List<dynamic> rawList = json.decode(responseText);
      final List<String> categories = rawList.map((item) => item.toString()).toList();
      
      // Update local storage cache
      await HiveLocalDatabase.instance.saveStringList(_dbKey, categories);
      return categories;
    } catch (e) {
      if (kDebugMode) {
        print("CategoryRepo: Server offline ($e). Loading from local database...");
      }
    }

    // Fallback: Read from local HiveLocalDatabase
    final localList = await HiveLocalDatabase.instance.getStringList(_dbKey);
    if (localList != null) {
      return localList;
    }

    // Secondary Fallback: default seeded mock list
    return List.from(_defaultCategories);
  }

  @override
  Future<void> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;

    final serverUrl = await _syncService.fetchDynamicServerUrl();
    
    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('$serverUrl/api/categories');
      final request = await httpClient.postUrl(uri);
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode({'category': trimmed})));
      
      final response = await request.close();
      httpClient.close();
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("CategoryRepo: Successfully added category to server.");
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print("CategoryRepo: Failed to send new category to server. Adding to offline queue.");
      }
    }

    // Offline mode: Write locally and queue sync operation
    final currentLocal = await getCategories();
    if (!currentLocal.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      currentLocal.add(trimmed);
      await HiveLocalDatabase.instance.saveStringList(_dbKey, currentLocal);
    }
    
    // Add to pending queue
    await HiveLocalDatabase.instance.addToQueue('addCategory', {'category': trimmed});
  }

  @override
  Future<void> deleteCategory(String category) async {
    final trimmed = category.trim();
    final serverUrl = await _syncService.fetchDynamicServerUrl();
    
    try {
      final httpClient = HttpClient();
      final uri = Uri.parse('$serverUrl/api/categories/$trimmed');
      final request = await httpClient.deleteUrl(uri);
      
      final response = await request.close();
      httpClient.close();
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("CategoryRepo: Successfully deleted category from server.");
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print("CategoryRepo: Failed to send delete category to server. Queueing offline task.");
      }
    }

    // Offline mode: Remove locally and queue sync operation
    final currentLocal = await getCategories();
    currentLocal.removeWhere((c) => c.toLowerCase() == trimmed.toLowerCase());
    await HiveLocalDatabase.instance.saveStringList(_dbKey, currentLocal);
    
    // Add to pending queue
    await HiveLocalDatabase.instance.addToQueue('deleteCategory', {'category': trimmed});
  }

  @override
  Future<void> syncPendingQueue() async {
    final queue = await HiveLocalDatabase.instance.getQueue();
    if (queue.isEmpty) return;

    if (kDebugMode) {
      print("CategoryRepo: Found ${queue.length} pending offline sync tasks. Syncing...");
    }

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

      try {
        final httpClient = HttpClient();
        if (action == 'addCategory') {
          final uri = Uri.parse('$serverUrl/api/categories');
          final request = await httpClient.postUrl(uri);
          request.headers.set('content-type', 'application/json');
          request.add(utf8.encode(json.encode({'category': payload['category']})));
          final response = await request.close();
          if (response.statusCode != 200) throw Exception("Failed");
        } else if (action == 'deleteCategory') {
          final uri = Uri.parse('$serverUrl/api/categories/${payload['category']}');
          final request = await httpClient.deleteUrl(uri);
          final response = await request.close();
          if (response.statusCode != 200) throw Exception("Failed");
        }
        httpClient.close();
      } catch (e) {
        if (kDebugMode) {
          print("CategoryRepo: Queue sync failed for task $action: $e. Pausing sync.");
        }
        failed = true;
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

// Mock implementation to preserve unit test execution integrity
class MockCategoryRepository implements CategoryRepository {
  final List<String> _categories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Appliance',
    'Painting',
    'Carpentry',
    'Pest Control',
    'Salon',
  ];

  @override
  Future<List<String>> getCategories() async {
    return List.from(_categories);
  }

  @override
  Future<void> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isNotEmpty && !_categories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
      _categories.add(trimmed);
    }
  }

  @override
  Future<void> deleteCategory(String category) async {
    _categories.removeWhere((c) => c.toLowerCase() == category.toLowerCase());
  }

  @override
  Future<void> syncPendingQueue() async {}
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncedCategoryRepository(syncService);
});

final categoriesListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});
