import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrm/data/models/camera_module/classification_result_model.dart';

/// Service for saving prediction results to Firestore
/// 
/// Handles creating prediction documents in the 'predictions' collection
class PredictionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  PredictionService(this._firestore, this._firebaseAuth);

  /// Save a prediction to Firestore
  /// 
  /// [classificationResult] - The classification result from the API
  /// [userId] - The user ID (from Firebase Auth)
  /// [company] - The company name (from user's company field)
  /// 
  /// Returns the document ID of the created prediction
  Future<String> savePrediction({
    required ClassificationResult classificationResult,
    required String userId,
    required String companyName,
  }) async {
    try {
      // Build the model_response with nested layer1_result, layer2_result, and metadata
      final modelResponse = <String, dynamic>{
        'layer1_result': classificationResult.layer1Result.toJson(),
      };

      if (classificationResult.layer2Result != null) {
        modelResponse['layer2_result'] = classificationResult.layer2Result!.toJson();
      }

      if (classificationResult.metadata != null) {
        modelResponse['metadata'] = classificationResult.metadata!.toJson();
      }

      // Build the prediction document
      final predictionData = <String, dynamic>{
        'user_id': userId,
        'company': companyName,
        'created_at': FieldValue.serverTimestamp(),
        'image_url': classificationResult.imageUrl ?? '',
        'model_response': modelResponse,
        'user_feedback': {
          'reviewed_at': null,
          'is_correct': true, // Default to true
          'correct_l1_class': null,
          'correct_l2_class': null,
          'notes': null,
        },
      };

      // Add document to Firestore
      final docRef = await _firestore.collection('predictions').add(predictionData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save prediction: $e');
    }
  }

  /// Save a prediction using the current logged-in user
  /// 
  /// [classificationResult] - The classification result from the API
  /// 
  /// Returns the document ID of the created prediction
  /// 
  /// Throws an exception if user is not logged in or user data is missing
  Future<String> savePredictionForCurrentUser({
    required ClassificationResult classificationResult,
    required Map<String, dynamic> currentUserData,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;
    final companyName = currentUserData['company'] as String?;

    if (companyName == null || companyName.isEmpty) {
      throw Exception('Company ID not found in user data');
    }

    return await savePrediction(
      classificationResult: classificationResult,
      userId: userId,
      companyName: companyName,
    );
  }
}

