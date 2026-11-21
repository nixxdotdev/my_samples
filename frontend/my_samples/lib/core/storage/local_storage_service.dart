import 'dart:convert';
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
  static const String _keySeenTour = 'has_seen_interactive_tour';

  // =========================================================================
  // [OFFLINE-FIRST DEPLOYMENT CONFIGURATION]
  // This APK is deployed as an offline-first app by default upon install.
  // The remote backend URL configuration is commented out for this release.
  //
  // NEXT STAGE OF DEVELOPMENT (ONLINE MODE):
  // When deploying the remote cloud backend (e.g. AWS, GCP, Railway, Render),
  // uncomment and configure the production endpoint below:
  //
  // static const String remoteBackendUrl = 'https://api.yourdomain.com';
  // static String get defaultLocalUrl {
  //   if (!kIsWeb && Platform.isAndroid) {
  //     return 'http://10.0.2.2:3000';
  //   }
  //   return 'http://localhost:3000';
  // }
  // =========================================================================
  static const String defaultLocalUrl = 'http://offline.local';

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
  Future<bool> saveCachedSamples(List<Map<String, dynamic>> samples) async {
    final p = await init();
    return await p.setString(_keySamplesCache, jsonEncode(samples));
  }

  List<Map<String, dynamic>>? getCachedSamples() {
    final raw = _prefs?.getString(_keySamplesCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      // Corrupt cache handling
    }
    return null;
  }

  // ---------------- NOTIFICATIONS CACHE ----------------
  Future<bool> saveCachedNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    final p = await init();
    return await p.setString(_keyNotificationsCache, jsonEncode(notifications));
  }

  List<Map<String, dynamic>>? getCachedNotifications() {
    final raw = _prefs?.getString(_keyNotificationsCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      // Corrupt cache handling
    }
    return null;
  }

  // ---------------- SYNC METADATA ----------------
  Future<bool> setLastSync(DateTime time) async {
    final p = await init();
    return await p.setString(_keyLastSync, time.toIso8601String());
  }

  DateTime? getLastSync() {
    final raw = _prefs?.getString(_keyLastSync);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // ---------------- OFFLINE TOGGLE ----------------
  Future<bool> setOfflineMode(bool isOffline) async {
    final p = await init();
    return await p.setBool(_keyOfflineMode, isOffline);
  }

  bool isOfflineModeEnabled() {
    return _prefs?.getBool(_keyOfflineMode) ?? true;
  }

  // ---------------- INTERACTIVE GUIDE TOUR ----------------
  Future<bool> setSeenInteractiveTour(bool seen) async {
    final p = await init();
    return await p.setBool(_keySeenTour, seen);
  }

  bool hasSeenInteractiveTour() {
    return _prefs?.getBool(_keySeenTour) ?? false;
  }

  Future<void> clearAll() async {
    final p = await init();
    await p.clear();
  }
}
