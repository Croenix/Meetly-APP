import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/database/local_database.dart';

// Helper to resolve the correct regional database instance
FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

abstract class CategoryRepository {
  Future<List<String>> getCategories();
  Future<void> addCategory(String category);
  Future<void> deleteCategory(String category);
  Future<void> syncPendingQueue();
}

class SyncedCategoryRepository implements CategoryRepository {
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

  SyncedCategoryRepository();

  @override
  Future<List<String>> getCategories() async {
    final localList = await HiveLocalDatabase.instance.getStringList(_dbKey);
    if (localList != null) {
      return localList;
    }
    return List.from(_defaultCategories);
  }

  @override
  Future<void> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;

    // Proactively try to sync pending queue first
    await syncPendingQueue();

    try {
      final dbRef = _database.ref('categories');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      
      List<String> list = [];
      if (snapshot.exists) {
        final rawVal = snapshot.value;
        if (rawVal is List) {
          list = rawVal.map((item) => item.toString()).toList();
        } else if (rawVal is Map) {
          list = rawVal.values.map((item) => item.toString()).toList();
        }
      } else {
        list = await getCategories();
      }

      if (!list.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
        list.add(trimmed);
        await dbRef.set(list);
        await HiveLocalDatabase.instance.saveStringList(_dbKey, list);
        if (kDebugMode) {
          print("CategoryRepo: Added category directly to Firebase RTDB.");
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print("CategoryRepo: Failed to write to Firebase. Adding to offline queue.");
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

    // Proactively try to sync pending queue first
    await syncPendingQueue();

    try {
      final dbRef = _database.ref('categories');
      final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
      
      List<String> list = [];
      if (snapshot.exists) {
        final rawVal = snapshot.value;
        if (rawVal is List) {
          list = rawVal.map((item) => item.toString()).toList();
        } else if (rawVal is Map) {
          list = rawVal.values.map((item) => item.toString()).toList();
        }
      } else {
        list = await getCategories();
      }

      list.removeWhere((c) => c.toLowerCase() == trimmed.toLowerCase());
      await dbRef.set(list);
      await HiveLocalDatabase.instance.saveStringList(_dbKey, list);
      if (kDebugMode) {
        print("CategoryRepo: Deleted category directly from Firebase RTDB.");
      }
      return;
    } catch (e) {
      if (kDebugMode) {
        print("CategoryRepo: Failed to delete category from Firebase. Queueing offline task.");
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
      print("CategoryRepo: Found ${queue.length} pending offline sync tasks. Syncing directly to Firebase...");
    }

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
        final dbRef = _database.ref('categories');
        final snapshot = await dbRef.get().timeout(const Duration(seconds: 3));
        
        List<String> list = [];
        if (snapshot.exists) {
          final rawVal = snapshot.value;
          if (rawVal is List) {
            list = rawVal.map((item) => item.toString()).toList();
          } else if (rawVal is Map) {
            list = rawVal.values.map((item) => item.toString()).toList();
          }
        } else {
          list = await getCategories();
        }

        if (action == 'addCategory') {
          final trimmed = payload['category'].toString().trim();
          if (!list.any((c) => c.toLowerCase() == trimmed.toLowerCase())) {
            list.add(trimmed);
          }
        } else if (action == 'deleteCategory') {
          final trimmed = payload['category'].toString().trim();
          list.removeWhere((c) => c.toLowerCase() == trimmed.toLowerCase());
        }

        await dbRef.set(list);
        await HiveLocalDatabase.instance.saveStringList(_dbKey, list);
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
  return SyncedCategoryRepository();
});

// StreamProvider listening directly to Realtime Database /categories node
final categoriesListProvider = StreamProvider<List<String>>((ref) {
  try {
    return _database.ref('categories').onValue.map((event) {
      final rawVal = event.snapshot.value;
      List<String> list = [];
      if (rawVal is List) {
        list = rawVal.map((item) => item.toString()).toList();
      } else if (rawVal is Map) {
        list = rawVal.values.map((item) => item.toString()).toList();
      }
      
      if (list.isNotEmpty) {
        // Cache to local SQLite/SharedPreferences asynchronously
        HiveLocalDatabase.instance.saveStringList('categories', list);
      }
      return list;
    });
  } catch (e) {
    if (kDebugMode) {
      print("CategoryRepo Stream: Error connecting to Firebase ($e). Falling back to local cache.");
    }
    // Fallback stream from local DB
    return Stream.fromFuture(
      HiveLocalDatabase.instance.getStringList('categories').then((localList) {
        return localList ?? [
          'Cleaning',
          'Plumbing',
          'Electrical',
          'Appliance',
          'Painting',
          'Carpentry',
          'Pest Control',
          'Salon'
        ];
      })
    );
  }
});
