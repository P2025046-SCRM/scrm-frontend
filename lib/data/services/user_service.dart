import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrm/data/services/storage_service.dart';
import 'package:scrm/utils/logger.dart';

/// Helper function to convert Firestore Timestamp objects to JSON-serializable format
/// Converts Timestamp to ISO 8601 string format
Map<String, dynamic> _convertTimestampsToJson(Map<String, dynamic> data) {
  final converted = <String, dynamic>{};
  data.forEach((key, value) {
    if (value is Timestamp) {
      // Convert Firestore Timestamp to ISO 8601 string
      converted[key] = value.toDate().toIso8601String();
    } else if (value is Map) {
      // Recursively convert nested maps
      converted[key] = _convertTimestampsToJson(Map<String, dynamic>.from(value));
    } else {
      converted[key] = value;
    }
  });
  return converted;
}

/// Service for user profile operations
/// 
/// Handles fetching and updating user profile data
/// Uses Firestore as primary data source
class UserService {
  final StorageService _storageService;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _firebaseAuth;

  UserService(this._storageService, [this._firestore, this._firebaseAuth]);

  /// Get current user profile
  /// 
  /// Returns user data as a Map
  /// Uses Firestore if available, otherwise falls back to Firebase Auth
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // Try Firestore first if available
      if (_firestore != null && _firebaseAuth != null) {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            final firestoreData = userDoc.data() as Map<String, dynamic>;
            AppLogger.logDebug('Firestore user data: $firestoreData');
            
            // Build data map: Firestore data first (has 'name'), then Firebase Auth data as fallback
            final data = <String, dynamic>{
              // Start with Firestore data (includes: name, email, createdAt, updatedAt)
              ...firestoreData,
              // Then add/override with Firebase Auth data for consistency
              'uid': user.uid,
              'email': firestoreData['email'] ?? user.email ?? '',
              'emailVerified': user.emailVerified,
              'displayName': user.displayName ?? firestoreData['name'] ?? '',
            };
            
            // Ensure 'name' exists - prioritize Firestore 'name'
            if (!data.containsKey('name') || data['name'] == null || (data['name'] as String).isEmpty) {
              data['name'] = user.displayName ?? '';
              AppLogger.logWarning('name not found in Firestore, using displayName: ${data['name']}');
            } else {
              AppLogger.logDebug('Using name from Firestore: ${data['name']}');
            }
            
            AppLogger.logDebug('Final user data: $data');
            
            // Convert Timestamp objects to JSON-serializable format before caching
            final serializableData = _convertTimestampsToJson(data);
            
            // Cache user data locally (with Timestamps converted to strings)
            await _storageService.saveUserData(serializableData);
            
            // Return original data (with Timestamps) for immediate use
            return data;
          } else {
            AppLogger.logWarning('Firestore user document does not exist for UID: ${user.uid}');
          }
        }
      }

      // If Firestore is not available or user doc doesn't exist, get basic info from Firebase Auth
      if (_firebaseAuth != null) {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          return {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'name': user.displayName ?? '', // Use displayName as name fallback
            'emailVerified': user.emailVerified,
          };
        }
      }

      throw Exception('No user data available');
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  /// 
  /// [name] - Updated name (optional)
  /// [email] - Updated email (optional)
  /// 
  /// Returns updated user data
  /// Uses Firestore to update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      // Firestore must be available for profile updates
      if (_firestore == null || _firebaseAuth == null) {
        throw Exception('Firestore is not available');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (name != null) {
        updateData['name'] = name;
        // Also update Firebase Auth display name
        await user.updateDisplayName(name);
      }
      if (email != null) {
        updateData['email'] = email;
        // Update email in Firebase Auth
        await user.updateEmail(email);
      }

      await _firestore.collection('users').doc(user.uid).set(
        updateData,
        SetOptions(merge: true),
      );

      // Reload user to get updated data
      await user.reload();
      
      // Get updated user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw Exception('User not found after update');
      }
      
      final userDocData = userDoc.data() ?? <String, dynamic>{};
      final data = {
        'uid': updatedUser.uid,
        'email': updatedUser.email,
        'displayName': updatedUser.displayName,
        'emailVerified': updatedUser.emailVerified,
        ...userDocData,
      };

      // Convert Timestamp objects to JSON-serializable format before caching
      final serializableData = _convertTimestampsToJson(data);
      
      // Update cached user data (with Timestamps converted to strings)
      await _storageService.saveUserData(serializableData);
      
      // Return original data (with Timestamps) for immediate use
      return data;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload profile picture
  /// 
  /// [imageBase64] - Base64 encoded image string
  /// 
  /// Returns updated user data with new profile picture URL
  /// Note: Profile picture upload functionality needs to be implemented with Firebase Storage
  Future<Map<String, dynamic>> uploadProfilePicture(String imageBase64) async {
    throw Exception('Profile picture upload not yet implemented. Use Firebase Storage to implement this feature.');
  }

  /// Get cached user data from local storage
  Map<String, dynamic>? getCachedUserData() {
    return _storageService.getUserData();
  }
}

