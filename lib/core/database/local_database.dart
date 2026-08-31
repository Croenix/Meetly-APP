import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class HiveLocalDatabase {
  static const String _keyPrefix = 'meetly_local_db_';
  static const String _queueKey = 'meetly_sync_queue';

  // Singleton pattern
  static final HiveLocalDatabase instance = HiveLocalDatabase._internal();
  HiveLocalDatabase._internal();

  // Save a single String
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$key', value);
  }

  // Get a single String
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix$key');
  }

  // Save a list of Strings (e.g. categories)
  Future<void> saveStringList(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('$_keyPrefix$key', list);
    if (kDebugMode) {
      print("LocalDB: Saved StringList for key '$key' (${list.length} items).");
    }
  }

  // Get a list of Strings
  Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_keyPrefix$key');
  }

  // Save a list of Maps (e.g. providers)
  Future<void> saveMapList(String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => json.encode(item)).toList();
    await prefs.setStringList('$_keyPrefix$key', jsonList);
    if (kDebugMode) {
      print("LocalDB: Saved MapList for key '$key' (${list.length} items).");
    }
  }

  // Get a list of Maps
  Future<List<Map<String, dynamic>>?> getMapList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('$_keyPrefix$key');
    if (jsonList == null) return null;
    try {
      return jsonList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("LocalDB: Error parsing MapList for key '$key' ($e).");
      }
      return null;
    }
  }

  // --- OFFLINE SYNC PENDING QUEUE ---
  
  // Add operation to pending queue when server is offline
  Future<void> addToQueue(String action, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_queueKey) ?? [];
    
    final operation = {
      'action': action,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String()
    };
    
    queueJson.add(json.encode(operation));
    await prefs.setStringList(_queueKey, queueJson);
    if (kDebugMode) {
      print("LocalDB: Added offline sync task '$action' to pending queue.");
    }
  }

  // Get all pending operations
  Future<List<Map<String, dynamic>>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_queueKey) ?? [];
    try {
      return queueJson
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Alias helper for queue retrieval
  Future<List<Map<String, dynamic>>> getPendingQueue() => getQueue();

  // Clear pending queue
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    if (kDebugMode) {
      print("LocalDB: Cleared pending sync queue.");
    }
  }
}
