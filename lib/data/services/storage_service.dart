import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

/// Service for managing local storage using SharedPreferences
/// 
/// Provides methods for saving and retrieving authentication tokens,
/// user data, settings, and classification history
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  /// Private constructor for singleton pattern
  StorageService._();

  /// Get singleton instance
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Save authentication token
  Future<bool> saveToken(String token) async {
    return await _prefs?.setString(StorageKeys.authToken, token) ?? false;
  }

  /// Get authentication token
  String? getToken() {
    return _prefs?.getString(StorageKeys.authToken);
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    return await _prefs?.setString(StorageKeys.refreshToken, token) ?? false;
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _prefs?.getString(StorageKeys.refreshToken);
  }

  /// Save user data as JSON string
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = json.encode(userData);
    return await _prefs?.setString(StorageKeys.userData, jsonString) ?? false;
  }

  /// Get user data from JSON string
  Map<String, dynamic>? getUserData() {
    final jsonString = _prefs?.getString(StorageKeys.userData);
    if (jsonString == null) return null;
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save theme mode (light/dark)
  Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs?.setString(StorageKeys.themeMode, themeMode) ?? false;
  }

  /// Get theme mode
  String? getThemeMode() {
    return _prefs?.getString(StorageKeys.themeMode);
  }

  /// Save language preference
  Future<bool> saveLanguage(String language) async {
    return await _prefs?.setString(StorageKeys.language, language) ?? false;
  }

  /// Get language preference
  String? getLanguage() {
    return _prefs?.getString(StorageKeys.language);
  }

  /// Save classification history as JSON array
  Future<bool> saveClassificationHistory(List<Map<String, dynamic>> history) async {
    final jsonString = json.encode(history);
    return await _prefs?.setString(StorageKeys.classificationHistory, jsonString) ?? false;
  }

  /// Get classification history from JSON array
  List<Map<String, dynamic>>? getClassificationHistory() {
    final jsonString = _prefs?.getString(StorageKeys.classificationHistory);
    if (jsonString == null) return null;
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored data
  Future<bool> clearStorage() async {
    return await _prefs?.clear() ?? false;
  }

  /// Remove specific key from storage
  Future<bool> removeKey(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
}