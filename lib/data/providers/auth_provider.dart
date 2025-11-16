import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Provider for authentication state management
/// 
/// Manages user authentication state, login, signup, and logout operations
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _checkAuthenticationStatus();
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Check if authentication operation is in progress
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Check authentication status from storage
  Future<void> _checkAuthenticationStatus() async {
    _isAuthenticated = _authService.isAuthenticated();
    notifyListeners();
  }

  /// Login with email and password
  /// 
  /// [email] - User email address
  /// [password] - User password
  /// 
  /// Returns true if login successful, false otherwise
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      _isAuthenticated = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign up a new user
  /// 
  /// [name] - User full name
  /// [email] - User email address
  /// [password] - User password
  /// 
  /// Returns true if signup successful, false otherwise
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signup(
        name: name,
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      // Even if logout fails, clear local state
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  /// 
  /// [email] - User email address
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize authentication state from storage
  Future<void> initialize() async {
    await _checkAuthenticationStatus();
  }
}

