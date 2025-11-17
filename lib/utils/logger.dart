import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized logging utility using Firebase Crashlytics
/// 
/// Provides structured logging methods for errors, warnings, info, and debug messages
class AppLogger {
  /// Log an error with optional stack trace and context
  /// 
  /// [error] - The error object or message
  /// [stackTrace] - Optional stack trace
  /// [reason] - Optional reason or context for the error
  /// [fatal] - Whether the error is fatal (default: false)
  static Future<void> logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      // In debug mode, also print to console for immediate visibility
      print('ERROR: $error');
      if (reason != null) print('Reason: $reason');
      if (stackTrace != null) print('Stack trace: $stackTrace');
    }
    
    // Record to Crashlytics
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace ?? StackTrace.current,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Log an info message
  /// 
  /// [message] - The message to log
  static void logInfo(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
    FirebaseCrashlytics.instance.log(message);
  }

  /// Log a warning message
  /// 
  /// [message] - The warning message to log
  static void logWarning(String message) {
    if (kDebugMode) {
      print('WARNING: $message');
    }
    FirebaseCrashlytics.instance.log('[WARNING] $message');
  }

  /// Log a debug message (only logged in debug mode)
  /// 
  /// [message] - The debug message to log
  static void logDebug(String message) {
    if (kDebugMode) {
      print('DEBUG: $message');
      // Optionally log to Crashlytics in debug builds for development tracking
      FirebaseCrashlytics.instance.log('[DEBUG] $message');
    }
  }

  /// Log a success message (treated as info)
  /// 
  /// [message] - The success message to log
  static void logSuccess(String message) {
    if (kDebugMode) {
      print('SUCCESS: $message');
    }
    FirebaseCrashlytics.instance.log('[SUCCESS] $message');
  }

  /// Set a custom key-value pair for crash reports
  /// 
  /// [key] - The key name
  /// [value] - The value (string)
  static Future<void> setCustomKey(String key, String value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Set user identifier for crash reports
  /// 
  /// [identifier] - User ID or email
  static Future<void> setUserIdentifier(String identifier) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }
}

