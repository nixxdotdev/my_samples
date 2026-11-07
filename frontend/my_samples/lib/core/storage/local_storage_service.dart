import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing local key-value and JSON persistence
/// across app sessions using SharedPreferences.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  static const String _keyAuthToken = 'auth_token';
  static const String _keyBackendUrl = 'backend_url';
  static const String _keySamplesCache = 'cached_samples_json';
  static const String _keyNotificationsCache = 'cached_notifications_json';
  static const String _keyLastSync = 'last_sync_timestamp';
  static const String _keyOfflineMode = 'offline_mode_enabled';

  // Default local backend URL (10.0.2.2 for Android emulator, localhost for desktop/iOS/Web)
  static String get defaultLocalUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Future<SharedPreferences> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------------- AUTH TOKEN ----------------
  Future<bool> saveAuthToken(String token) async {
    final p = await init();
    return await p.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return _prefs?.getString(_keyAuthToken);
  }

  Future<bool> removeAuthToken() async {
    final p = await init();
    return await p.remove(_keyAuthToken);
  }

  // ---------------- BACKEND URL CONFIG ----------------
  Future<bool> saveBackendUrl(String url) async {
    final p = await init();
    return await p.setString(_keyBackendUrl, url);
  }

  String getBackendUrl() {
    return _prefs?.getString(_keyBackendUrl) ?? defaultLocalUrl;
  }

  // ---------------- SAMPLES CACHE ----------------
  Future<bool> saveSamples(List<Map<String, dynamic>> samplesJson) async {
    try {
      final p = await init();
      final jsonString = jsonEncode(samplesJson);
      return await p.setString(_keySamplesCache, jsonString);
    } catch (e) {
      debugPrint('Error saving samples to cache: $e');
      return false;
    }
  }

  List<Map<String, dynamic>>? getCachedSamples() {
    final jsonString = _prefs?.getString(_keySamplesCache);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error parsing cached samples: $e');
      return null;
    }
  }

  // ---------------- NOTIFICATIONS CACHE ----------------
  Future<bool> saveNotifications(List<Map<String, dynamic>> notifsJson) async {
    try {
      final p = await init();
      final jsonString = jsonEncode(notifsJson);
      return await p.setString(_keyNotificationsCache, jsonString);
    } catch (e) {
      debugPrint('Error saving notifications to cache: $e');
      return false;
    }
  }

  List<Map<String, dynamic>>? getCachedNotifications() {
    final jsonString = _prefs?.getString(_keyNotificationsCache);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error parsing cached notifications: $e');
      return null;
    }
  }

  // ---------------- SYNC & STATUS ----------------
  Future<bool> setLastSync(DateTime time) async {
    final p = await init();
    return await p.setInt(_keyLastSync, time.millisecondsSinceEpoch);
  }

  DateTime? getLastSync() {
    final ms = _prefs?.getInt(_keyLastSync);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<bool> setOfflineMode(bool enabled) async {
    final p = await init();
    return await p.setBool(_keyOfflineMode, enabled);
  }

  bool isOfflineMode() {
    return _prefs?.getBool(_keyOfflineMode) ?? false;
  }

  Future<void> clearAll() async {
    final p = await init();
    await p.clear();
  }
}
