import 'package:flutter/material.dart';

// Waste type classification constants
class WasteTypes {
  static const String reciclable = 'Reciclable';
  static const String noReciclable = 'NoReciclable';
  static const String retazos = 'Retazos';
  static const String biomasa = 'Biomasa';
  static const String metales = 'Metales';
  static const String plastico = 'Plastico';
}

// Application route name constants
class AppRouteNames {
  static const String login = 'login';
  static const String signup = 'signup';
  static const String profile = 'profile';
  static const String editProfile = 'edit_profile';
  static const String dashboard = 'dashboard';
  static const String history = 'history';
  static const String camera = 'camera';
}

// Storage keys for local persistence
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String classificationHistory = 'classification_history';
}

// Default application values
class AppDefaults {
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const double defaultConfidence = 0.0;
}

/// Reusable color constants
class AppColors {
  static const Color primaryGreen = Colors.lightGreen;
  static const Color recyclableGreen = Colors.green;
  static const Color nonRecyclableRed = Colors.red;
  static const Color retazosOrange = Color.fromARGB(255, 193, 123, 25);
  static const Color biomasaGreen = Color.fromARGB(255, 71, 178, 29);
  static const Color metalesGray = Color.fromARGB(255, 146, 155, 170);
  static const Color plasticosBlue = Color.fromARGB(255, 6, 17, 167);
  static const Color textHint = Color(0xFF757575);
  static const Color accentGreen = Color.fromARGB(255, 99, 135, 99);
}

