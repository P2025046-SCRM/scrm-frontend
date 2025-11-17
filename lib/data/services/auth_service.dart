import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrm/data/services/storage_service.dart';
import 'package:scrm/utils/logger.dart';

/// Service for authentication operations using Firebase Auth
/// 
/// Handles login, signup, logout, and token management
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  AuthService(this._firebaseAuth, this._firestore, this._storageService);

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Login with email and password using Firebase Auth
  /// 
  /// Returns a map containing user data
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed: No user returned');
      }

      final user = userCredential.user!;
      
      // Get ID token for Firebase authentication (stored for potential future use)
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _storageService.saveToken(idToken);
      }

      // Get user data from Firestore if available
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': user.email,
        'emailVerified': user.emailVerified,
        'displayName': user.displayName,
      };

      // Try to get additional user data from Firestore
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final firestoreData = userDoc.data() as Map<String, dynamic>;
          userData.addAll(firestoreData);
          // Ensure 'name' exists - use Firestore 'name' or fallback to displayName
          if (!userData.containsKey('name') || userData['name'] == null) {
            userData['name'] = user.displayName ?? '';
          }
        } else {
          // If Firestore doc doesn't exist yet, use displayName as name fallback
          userData['name'] = user.displayName ?? '';
        }
      } catch (e, stackTrace) {
        // If Firestore read fails, continue with basic user data
        AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to fetch user data from Firestore during login');
        // Use displayName as name fallback
        userData['name'] = user.displayName ?? '';
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No se encontró un usuario con este email';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          errorMessage = 'Dirección de email inválida';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta de usuario ha sido deshabilitada';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos fallidos. Por favor, intente más tarde';
          break;
        case 'network-request-failed':
          errorMessage = 'Error de conexión. Verifique su conexión a internet';
          break;
        default:
          errorMessage = 'Error al iniciar sesión: ${e.message ?? "Error desconocido"}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Sign up a new user with Firebase Auth
  /// 
  /// Returns a map containing user data
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Signup failed: No user returned');
      }

      final user = userCredential.user!;

      // Update display name
      await user.updateDisplayName(name);
      await user.reload();

      // Get ID token
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _storageService.saveToken(idToken);
      }

      // Save additional user data to Firestore
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email.trim(),
          'company': '3J Solutions', // Hardcoded company name, would be dynamic when the app becomes multi-company
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e, stackTrace) {
        // If Firestore write fails, continue with basic user creation
        AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to save user data to Firestore during signup');
      }

      // Return user data
      final updatedUser = _firebaseAuth.currentUser!;
      Map<String, dynamic> userData = {
        'uid': updatedUser.uid,
        'email': updatedUser.email,
        'emailVerified': updatedUser.emailVerified,
        'displayName': updatedUser.displayName ?? name,
        'name': name, // Ensure 'name' is always set from registration
        'company': '3J Solutions', // Hardcoded company name
      };

      // Try to get full user data from Firestore and merge it
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final firestoreData = userDoc.data() as Map<String, dynamic>;
          // Merge Firestore data, but keep 'name' from registration if Firestore doesn't have it
          userData.addAll(firestoreData);
          // Ensure 'name' exists - prioritize Firestore 'name', but keep registration 'name' as fallback
          if (!userData.containsKey('name') || userData['name'] == null || (userData['name'] as String).isEmpty) {
            userData['name'] = name;
          }
        }
      } catch (e, stackTrace) {
        AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to fetch user data from Firestore during signup');
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al crear la cuenta';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este email ya está registrado';
          break;
        case 'invalid-email':
          errorMessage = 'Dirección de email inválida';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil. Use al menos 6 caracteres';
          break;
        case 'network-request-failed':
          errorMessage = 'Error de conexión. Verifique su conexión a internet';
          break;
        default:
          errorMessage = 'Error al crear la cuenta: ${e.message ?? "Error desconocido"}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error al crear la cuenta: $e');
    }
  }

  /// Logout user from Firebase and clear tokens
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, stackTrace) {
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Firebase logout error');
    } finally {
      // Clear local storage
      await _storageService.clearStorage();
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get current user's ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken(forceRefresh);
      
      // Cache token in storage
      if (token != null) {
        await _storageService.saveToken(token);
      }
      
      return token;
    } catch (e, stackTrace) {
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to get ID token');
      return null;
    }
  }

  /// Refresh authentication token
  Future<String> refreshToken() async {
    try {
      final token = await getIdToken(forceRefresh: true);
      if (token == null) {
        throw Exception('No user logged in');
      }
      return token;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al enviar el email de restablecimiento';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No se encontró un usuario con este email';
          break;
        case 'invalid-email':
          errorMessage = 'Dirección de email inválida';
          break;
        case 'network-request-failed':
          errorMessage = 'Error de conexión. Verifique su conexión a internet';
          break;
        default:
          errorMessage = 'Error al enviar el email de restablecimiento: ${e.message ?? "Error desconocido"}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error al enviar el email de restablecimiento: $e');
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}

