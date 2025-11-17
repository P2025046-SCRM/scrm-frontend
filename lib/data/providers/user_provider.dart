import 'package:flutter/foundation.dart';
import '../services/user_service.dart';
import '../../utils/logger.dart';

/// Provider for user profile state management
/// 
/// Manages current user data and profile updates
class UserProvider extends ChangeNotifier {
  final UserService _userService;

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider(this._userService) {
    _loadCachedUserData();
  }

  /// Get current user data
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Get current user name
  /// 
  /// Returns 'name' from Firestore if available, otherwise falls back to 'displayName' from Firebase Auth
  String? get userName {
    if (_currentUser == null) {
      AppLogger.logDebug('userName: currentUser is null');
      return null;
    }
    // Try 'name' first (from Firestore), then 'displayName' (from Firebase Auth)
    final name = _currentUser!['name'] as String?;
    final displayName = _currentUser!['displayName'] as String?;
    final result = name ?? displayName;
    AppLogger.logDebug('userName getter: name=$name, displayName=$displayName, result=$result');
    return result;
  }

  /// Get current user email
  String? get userEmail => _currentUser?['email'] as String?;

  /// Get current user company
  String? get userCompany => _currentUser?['company'] as String?;

  /// Check if user data is loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Load cached user data from local storage
  void _loadCachedUserData() {
    final cachedData = _userService.getCachedUserData();
    if (cachedData != null) {
      AppLogger.logDebug('Loaded cached user data: $cachedData');
      AppLogger.logDebug('Cached name: ${cachedData['name']}');
      _currentUser = cachedData;
    } else {
      AppLogger.logDebug('No cached user data found');
    }
    notifyListeners();
  }

  /// Fetch current user data from Firestore
  Future<void> fetchUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedUser = await _userService.getCurrentUser();
      AppLogger.logDebug('Fetched user data: $fetchedUser');
      AppLogger.logDebug('Fetched name: ${fetchedUser['name']}');
      _currentUser = fetchedUser;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error fetching user data');
      notifyListeners();
      rethrow;
    }
  }

  /// Update user profile
  /// 
  /// [name] - Updated name (optional)
  /// [email] - Updated email (optional)
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _userService.updateProfile(
        name: name,
        email: email,
      );
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear user data (useful on logout)
  void clearUserData() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}





