import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:scrm/utils/logger.dart';

/// Service for managing Firebase Remote Config
/// 
/// Handles fetching and providing application configuration values
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService(this._remoteConfig);

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await _remoteConfig.setDefaults({
        'API_BASE_URL': 'https://wfwastenet-api.eastus2.inference.ml.azure.com/score',
        'API_KEY_BACKEND': '',
      });

      // Initial fetch and activate
      await fetchAndActivate();
    } catch (e, stackTrace) {
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to initialize Remote Config');
    }
  }

  /// Fetch and activate Remote Config values
  Future<bool> fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config fetched and activated: $updated');
      debugPrint('API_BASE_URL: $apiBaseUrl');
      AppLogger.logInfo('Remote Config fetched and activated: $updated');
      AppLogger.logInfo('API_BASE_URL: $apiBaseUrl');
      return updated;
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch and activate Remote Config: $e');
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to fetch and activate Remote Config');
      return false;
    }
  }

  /// Get API Base URL
  String get apiBaseUrl => _remoteConfig.getString('API_BASE_URL');

  /// Get API Key Backend (Bearer Token)
  String get apiKeyBackend => _remoteConfig.getString('API_KEY_BACKEND');
}
