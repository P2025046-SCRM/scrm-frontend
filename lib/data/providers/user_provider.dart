import 'package:flutter/foundation.dart';
import '../services/user_service.dart';

/// Provider for user profile state management
/// 
/// Manages current user data, profile updates, and profile picture uploads
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
      print('userName: currentUser is null');
      return null;
    }
    // Try 'name' first (from Firestore), then 'displayName' (from Firebase Auth)
    final name = _currentUser!['name'] as String?;
    final displayName = _currentUser!['displayName'] as String?;
    final result = name ?? displayName;
    print('userName getter: name=$name, displayName=$displayName, result=$result'); // Debug
    return result;
  }

  /// Get current user email
  String? get userEmail => _currentUser?['email'] as String?;

  /// Get current user company
  String? get userCompany => _currentUser?['company'] as String?;

  /// Get current user profile picture URL
  String? get profilePictureUrl => _currentUser?['profile_picture'] as String?;

  /// Check if user data is loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Load cached user data from local storage
  void _loadCachedUserData() {
    final cachedData = _userService.getCachedUserData();
    if (cachedData != null) {
      print('Loaded cached user data: $cachedData'); // Debug
      print('Cached name: ${cachedData['name']}'); // Debug
      _currentUser = cachedData;
    } else {
      print('No cached user data found'); // Debug
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
      print('Fetched user data: $fetchedUser'); // Debug: Check fetched data
      print('Fetched name: ${fetchedUser['name']}'); // Debug: Check name field
      _currentUser = fetchedUser;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      print('Error fetching user data: $e'); // Debug: Check for errors
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

  /// Upload profile picture
  /// 
  /// [imageBase64] - Base64 encoded image string
  Future<void> uploadProfilePicture(String imageBase64) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _userService.uploadProfilePicture(imageBase64);
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





