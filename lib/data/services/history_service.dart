import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrm/data/services/storage_service.dart';

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
  /// 
  /// Returns list of classification records in a format compatible with
  /// the history screen (image_path, layer1_result, layer2_result, metadata, timestamp).
  Future<List<Map<String, dynamic>>> getHistory({
    required String companyName,
    int? limit,
  }) async {
    try {
      Query collection = _firestore
          .collection('predictions')
          .where('company', isEqualTo: companyName)
          .orderBy('created_at', descending: true);

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
        };
      }).toList();

      // Cache history locally
      await _storageService.saveClassificationHistory(history);

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
    } catch (e) {
      print('Error fetching latest prediction: $e');
      return null;
    }
  }
}





