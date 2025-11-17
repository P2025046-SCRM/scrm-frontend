import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/logger.dart';

/// Provider for admin dashboard statistics state management
/// 
/// Manages global dashboard statistics, metrics, and charts data
/// Fetches data from Firestore predictions and users collections across all companies
class AdminDashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardProvider(this._firestore);

  /// Get dashboard statistics
  Map<String, dynamic>? get statistics => _statistics;

  /// Check if statistics are loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Get total predictions count (global)
  int get totalPredictions {
    return _statistics?['total_predictions'] as int? ?? 0;
  }

  /// Get total registered users count
  int get totalUsers {
    return _statistics?['total_users'] as int? ?? 0;
  }

  /// Get total active companies count (excluding "Admin")
  int get totalCompanies {
    return _statistics?['total_companies'] as int? ?? 0;
  }

  /// Get average total inference time
  double get averageTotalInferenceTime {
    return _statistics?['avg_total_inference_time'] as double? ?? 0.0;
  }

  /// Get average Layer 1 inference time
  double get averageLayer1InferenceTime {
    return _statistics?['avg_l1_inference_time'] as double? ?? 0.0;
  }

  /// Get average Layer 2 inference time
  double get averageLayer2InferenceTime {
    return _statistics?['avg_l2_inference_time'] as double? ?? 0.0;
  }

  /// Get waste type distribution (for bar chart) - global data
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

  /// Get global accuracy percentage (precision based on user feedback)
  double get globalAccuracyPercentage {
    final total = _statistics?['total_predictions'] as int? ?? 0;
    final correct = _statistics?['correct_count'] as int? ?? 0;
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  /// Fetch global dashboard statistics from Firestore
  /// Fetches data from all companies (not filtered by company)
  Future<void> fetchGlobalStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch all predictions (no company filter)
      final predictionsSnapshot = await _firestore
          .collection('predictions')
          .get();

      final predictions = predictionsSnapshot.docs;

      // Fetch all users
      final usersSnapshot = await _firestore
          .collection('users')
          .get();

      final users = usersSnapshot.docs;

      // Calculate statistics from predictions
      int totalPredictions = predictions.length;
      int correctCount = 0;
      double totalInferenceTimeSum = 0.0;
      double l1InferenceTimeSum = 0.0;
      double l2InferenceTimeSum = 0.0;
      int inferenceTimeCount = 0;
      int l1InferenceTimeCount = 0;
      int l2InferenceTimeCount = 0;

      // Waste type distribution (layer2 classes) - global
      final Map<String, int> wasteTypeCounts = {
        'Retazos': 0,
        'Biomasa': 0,
        'Metales': 0,
        'Plastico': 0,
        'Plásticos': 0, // Handle both spellings
      };

      // Get unique companies (excluding "Admin")
      final Set<String> uniqueCompanies = {};

      // Process each prediction
      for (var doc in predictions) {
        final data = doc.data();
        
        // Track company (excluding "Admin")
        final company = data['company'] as String?;
        if (company != null && company != 'Admin') {
          uniqueCompanies.add(company);
        }

        // Get layer2 prediction for waste type distribution
        final modelResponse = data['model_response'] as Map<String, dynamic>?;
        if (modelResponse != null) {
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

          // Get inference times from metadata (inside model_response)
          final metadata = modelResponse['metadata'] as Map<String, dynamic>?;
          if (metadata != null) {
            final totalTime = metadata['total_processing_time_seconds'] as num?;
            final l1Time = metadata['l1_inference_time_seconds'] as num?;
            final l2Time = metadata['l2_inference_time_seconds'] as num?;

            if (totalTime != null) {
              totalInferenceTimeSum += totalTime.toDouble();
              inferenceTimeCount++;
            }
            if (l1Time != null) {
              l1InferenceTimeSum += l1Time.toDouble();
              l1InferenceTimeCount++;
            }
            if (l2Time != null) {
              l2InferenceTimeSum += l2Time.toDouble();
              l2InferenceTimeCount++;
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

      // Calculate average inference times
      final avgTotalInferenceTime = inferenceTimeCount > 0 
          ? totalInferenceTimeSum / inferenceTimeCount 
          : 0.0;
      final avgL1InferenceTime = l1InferenceTimeCount > 0 
          ? l1InferenceTimeSum / l1InferenceTimeCount 
          : 0.0;
      final avgL2InferenceTime = l2InferenceTimeCount > 0 
          ? l2InferenceTimeSum / l2InferenceTimeCount 
          : 0.0;

      // Build statistics map
      _statistics = {
        'total_predictions': totalPredictions,
        'total_users': users.length,
        'total_companies': uniqueCompanies.length,
        'correct_count': correctCount,
        'avg_total_inference_time': avgTotalInferenceTime,
        'avg_l1_inference_time': avgL1InferenceTime,
        'avg_l2_inference_time': avgL2InferenceTime,
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
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error fetching admin dashboard statistics');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await fetchGlobalStatistics();
  }
}

