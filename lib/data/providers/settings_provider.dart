import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider for app settings state management
/// 
/// Manages theme mode (light/dark) and language preferences
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'es'; // Default to Spanish

  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  /// Get current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Get current language
  String get language => _language;

  /// Check if dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    final savedTheme = _storageService.getThemeMode();
    if (savedTheme != null) {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }

    final savedLanguage = _storageService.getLanguage();
    if (savedLanguage != null) {
      _language = savedLanguage;
    }

    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await _storageService.saveThemeMode(
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );

    notifyListeners();
  }

  /// Set theme mode explicitly
  /// 
  /// [mode] - Theme mode to set (light or dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await _storageService.saveThemeMode(
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    notifyListeners();
  }

  /// Set language preference
  /// 
  /// [lang] - Language code (e.g., 'es' for Spanish, 'en' for English)
  Future<void> setLanguage(String lang) async {
    _language = lang;

    await _storageService.saveLanguage(lang);

    notifyListeners();
  }
}

