import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrm/data/services/storage_service.dart';
import 'package:scrm/utils/logger.dart';

/// Service for classification history operations
/// 
/// Handles fetching and caching classification history
class HistoryService {
  final StorageService _storageService;
  final FirebaseFirestore _firestore;

  HistoryService(this._storageService, this._firestore);

  /// Get classification history from Firestore `predictions` collection
  /// filtered by company name.
  /// 
  /// [companyName] - Company name to filter predictions by.
  /// [limit] - Maximum number of records to fetch (optional).
  /// [startAfter] - Document snapshot to start after for pagination (optional).
  /// 
  /// Returns list of classification records in a format compatible with
  /// the history screen (image_path, layer1_result, layer2_result, metadata, timestamp).
  Future<List<Map<String, dynamic>>> getHistory({
    required String companyName,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query collection = _firestore
          .collection('predictions')
          .where('company', isEqualTo: companyName)
          .orderBy('created_at', descending: true);

      if (startAfter != null) {
        collection = collection.startAfterDocument(startAfter);
      }

      if (limit != null) {
        collection = collection.limit(limit);
      }

      final querySnapshot = await collection.get();

      final List<Map<String, dynamic>> history = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final modelResponse = data['model_response'] as Map<String, dynamic>?;

        final layer1Result = modelResponse?['layer1_result'] as Map<String, dynamic>?;
        final layer2Result = modelResponse?['layer2_result'] as Map<String, dynamic>?;
        final metadata = modelResponse?['metadata'] as Map<String, dynamic>?;

        final createdAt = data['created_at'];
        String timestampString = '';
        if (createdAt is Timestamp) {
          timestampString = createdAt.toDate().toIso8601String();
        } else if (createdAt is String) {
          timestampString = createdAt;
        }

        return <String, dynamic>{
          'id': doc.id,
          'image_path': data['image_url'] as String? ?? '',
          'image_url': data['image_url'] as String? ?? '', // Keep both for compatibility
          'layer1_result': layer1Result,
          'layer2_result': layer2Result,
          'metadata': metadata,
          'timestamp': timestampString, // Keep for backward compatibility
          'created_at_timestamp': timestampString, // Use this for created_at timestamp
          '_document_snapshot': doc, // Store document snapshot for pagination
        };
      }).toList();

      // Cache history locally (without document snapshots)
      final historyForCache = history.map((item) {
        final itemCopy = Map<String, dynamic>.from(item);
        itemCopy.remove('_document_snapshot');
        return itemCopy;
      }).toList();
      await _storageService.saveClassificationHistory(historyForCache);

      return history;
    } catch (e) {
      throw Exception('Failed to get history: $e');
    }
  }

  /// Get cached classification history from local storage
  List<Map<String, dynamic>>? getCachedHistory() {
    return _storageService.getClassificationHistory();
  }

  /// Add a new classification to local cache
  /// 
  /// [classification] - Classification data to add
  Future<void> addToCache(Map<String, dynamic> classification) async {
    final cachedHistory = getCachedHistory() ?? [];
    cachedHistory.insert(0, classification);
    
    // Keep only last 100 records in cache
    if (cachedHistory.length > 100) {
      cachedHistory.removeRange(100, cachedHistory.length);
    }

    await _storageService.saveClassificationHistory(cachedHistory);
  }

  /// Get the latest prediction for a company from Firestore
  /// 
  /// [companyName] - Company name to filter predictions by
  /// 
  /// Returns the most recent prediction document, or null if none exists
  Future<Map<String, dynamic>?> getLatestPrediction({
    required String companyName,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('predictions')
          .where('company', isEqualTo: companyName)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final modelResponse = data['model_response'] as Map<String, dynamic>?;

      final layer1Result = modelResponse?['layer1_result'] as Map<String, dynamic>?;
      final layer2Result = modelResponse?['layer2_result'] as Map<String, dynamic>?;
      final metadata = modelResponse?['metadata'] as Map<String, dynamic>?;

      final createdAt = data['created_at'];
      String timestampString = '';
      if (createdAt is Timestamp) {
        timestampString = createdAt.toDate().toIso8601String();
      } else if (createdAt is String) {
        timestampString = createdAt;
      }

      return <String, dynamic>{
        'id': doc.id,
        'image_path': data['image_url'] as String? ?? '',
        'image_url': data['image_url'] as String? ?? '',
        'layer1_result': layer1Result,
        'layer2_result': layer2Result,
        'metadata': metadata,
        'timestamp': timestampString,
        'created_at_timestamp': timestampString,
      };
    } catch (e, stackTrace) {
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error fetching latest prediction');
      return null;
    }
  }

  /// Get existing user feedback for a prediction document
  /// 
  /// [predictionId] - The document ID of the prediction
  /// 
  /// Returns the user feedback map, or null if not found
  Future<Map<String, dynamic>?> getUserFeedback({
    required String predictionId,
  }) async {
    try {
      final doc = await _firestore
          .collection('predictions')
          .doc(predictionId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      final userFeedback = data?['user_feedback'] as Map<String, dynamic>?;
      return userFeedback;
    } catch (e) {
      throw Exception('Failed to get user feedback: $e');
    }
  }

  /// Update user feedback for a prediction document
  /// 
  /// [predictionId] - The document ID of the prediction to update
  /// [isCorrect] - Whether the prediction was correct
  /// [correctL1Class] - Correct L1 class (Reciclable or NoReciclable) if incorrect
  /// [correctL2Class] - Correct L2 class (Retazos, Biomasa, Metales, Plásticos) if Reciclable
  /// [notes] - Optional notes from the user
  Future<void> updateUserFeedback({
    required String predictionId,
    required bool isCorrect,
    String? correctL1Class,
    String? correctL2Class,
    String? notes,
  }) async {
    try {
      final userFeedback = <String, dynamic>{
        'reviewed_at': FieldValue.serverTimestamp(),
        'is_correct': isCorrect,
        'correct_l1_class': correctL1Class,
        'correct_l2_class': correctL2Class,
        'notes': notes,
      };

      await _firestore
          .collection('predictions')
          .doc(predictionId)
          .update({'user_feedback': userFeedback});
    } catch (e) {
      throw Exception('Failed to update user feedback: $e');
    }
  }
}





