import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider for dashboard statistics state management
/// 
/// Manages dashboard statistics, metrics, and charts data
/// Fetches data from Firestore predictions collection filtered by company
class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider(this._firestore);

  /// Get dashboard statistics
  Map<String, dynamic>? get statistics => _statistics;

  /// Check if statistics are loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Get recyclable percentage
  double get recyclablePercentage {
    if (_statistics == null) return 0.0;
    final recyclable = _statistics!['recyclable_count'] as int? ?? 0;
    final total = _statistics!['total_count'] as int? ?? 1;
    return total > 0 ? (recyclable / total) * 100 : 0.0;
  }

  /// Get non-recyclable percentage
  double get nonRecyclablePercentage {
    return 100.0 - recyclablePercentage;
  }

  /// Get total processed units
  int get totalProcessed {
    return _statistics?['total_count'] as int? ?? 0;
  }

  /// Get recyclable count
  int get recyclableCount {
    return _statistics?['recyclable_count'] as int? ?? 0;
  }

  /// Get non-recyclable count
  int get nonRecyclableCount {
    return _statistics?['non_recyclable_count'] as int? ?? 0;
  }

  /// Get accuracy percentage (precision based on user feedback)
  double get accuracyPercentage {
    final total = _statistics?['total_count'] as int? ?? 0;
    final correct = _statistics?['correct_count'] as int? ?? 0;
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  /// Get waste type distribution (for bar chart)
  List<double> get wasteTypeDistribution {
    final distribution = _statistics?['waste_type_distribution'] as Map<String, dynamic>?;
    if (distribution == null) return [0.0, 0.0, 0.0, 0.0];

    return [
      (distribution['retazos'] as num? ?? 0).toDouble(),
      (distribution['biomasa'] as num? ?? 0).toDouble(),
      (distribution['metales'] as num? ?? 0).toDouble(),
      (distribution['plasticos'] as num? ?? 0).toDouble(),
    ];
  }

  /// Fetch dashboard statistics from Firestore predictions collection
  /// 
  /// [companyName] - The company name to filter predictions by
  Future<void> fetchStatistics({required String companyName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Query predictions filtered by company
      final querySnapshot = await _firestore
          .collection('predictions')
          .where('company', isEqualTo: companyName)
          .get();

      final predictions = querySnapshot.docs;

      // Calculate statistics from predictions
      int recyclableCount = 0;
      int nonRecyclableCount = 0;
      int totalCount = predictions.length;
      int correctCount = 0;

      // Waste type distribution (layer2 classes)
      final Map<String, int> wasteTypeCounts = {
        'Retazos': 0,
        'Biomasa': 0,
        'Metales': 0,
        'Plastico': 0,
        'Plásticos': 0, // Handle both spellings
      };

      // Process each prediction
      for (var doc in predictions) {
        final data = doc.data();
        
        // Get layer1 prediction
        final modelResponse = data['model_response'] as Map<String, dynamic>?;
        if (modelResponse != null) {
          final layer1Result = modelResponse['layer1_result'] as Map<String, dynamic>?;
          if (layer1Result != null) {
            final layer1Prediction = layer1Result['prediction'] as String? ?? '';
            if (layer1Prediction == 'Reciclable') {
              recyclableCount++;
            } else if (layer1Prediction == 'NoReciclable') {
              nonRecyclableCount++;
            }

            // Get layer2 prediction for waste type distribution
            final layer2Result = modelResponse['layer2_result'] as Map<String, dynamic>?;
            if (layer2Result != null) {
              final layer2Prediction = layer2Result['prediction'] as String? ?? '';
              // Handle both "Plastico" and "Plásticos" spellings
              final normalizedPrediction = layer2Prediction == 'Plásticos' || layer2Prediction == 'Plasticos' 
                  ? 'Plastico' 
                  : layer2Prediction;
              
              if (wasteTypeCounts.containsKey(normalizedPrediction)) {
                wasteTypeCounts[normalizedPrediction] = (wasteTypeCounts[normalizedPrediction] ?? 0) + 1;
              }
            }
          }
        }

        // Get user feedback for accuracy/precision calculation
        final userFeedback = data['user_feedback'] as Map<String, dynamic>?;
        if (userFeedback != null) {
          final isCorrect = userFeedback['is_correct'] as bool? ?? true;
          if (isCorrect) {
            correctCount++;
          }
        } else {
          // If no feedback, assume correct (default is true)
          correctCount++;
        }
      }

      // Combine Plastico counts (handle both spellings)
      final totalPlastico = (wasteTypeCounts['Plastico'] ?? 0) + (wasteTypeCounts['Plásticos'] ?? 0);

      // Build statistics map
      _statistics = {
        'total_count': totalCount,
        'recyclable_count': recyclableCount,
        'non_recyclable_count': nonRecyclableCount,
        'correct_count': correctCount,
        'waste_type_distribution': {
          'retazos': wasteTypeCounts['Retazos'] ?? 0,
          'biomasa': wasteTypeCounts['Biomasa'] ?? 0,
          'metales': wasteTypeCounts['Metales'] ?? 0,
          'plasticos': totalPlastico,
        },
      };

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Error fetching dashboard statistics: $e');
    }
  }

  /// Calculate percentages for recyclable materials
  /// 
  /// Returns a map with percentage breakdown by material type
  Map<String, double> getMaterialPercentages() {
    final distribution = wasteTypeDistribution;
    final total = distribution.fold<double>(0.0, (acc, value) => acc + value);
    
    if (total == 0) {
      return {
        'retazos': 0.0,
        'biomasa': 0.0,
        'metales': 0.0,
        'plasticos': 0.0,
      };
    }

    return {
      'retazos': (distribution[0] / total) * 100,
      'biomasa': (distribution[1] / total) * 100,
      'metales': (distribution[2] / total) * 100,
      'plasticos': (distribution[3] / total) * 100,
    };
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh statistics
  /// 
  /// [companyName] - The company name to filter predictions by
  Future<void> refresh({required String companyName}) async {
    await fetchStatistics(companyName: companyName);
  }
}





