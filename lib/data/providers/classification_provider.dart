import 'package:flutter/foundation.dart';
import '../services/history_service.dart';

/// Provider for classification history state management
/// 
/// Manages classification history, recent classifications, and caching
/// Fetches data from Firestore predictions collection filtered by company
class ClassificationProvider extends ChangeNotifier {
  final HistoryService _historyService;

  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  ClassificationProvider(this._historyService) {
    _loadCachedHistory();
  }

  /// Get classification history
  List<Map<String, dynamic>> get history => _history;

  /// Check if history is loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Get history count
  int get historyCount => _history.length;

  /// Load cached history from local storage
  void _loadCachedHistory() {
    final cachedHistory = _historyService.getCachedHistory();
    if (cachedHistory != null) {
      _history = cachedHistory;
      notifyListeners();
    }
  }

  /// Fetch classification history from Firestore
  /// 
  /// [companyName] - Company name to filter predictions by (required)
  /// [limit] - Maximum number of records to fetch (optional)
  /// [forceRefresh] - Force refresh from Firestore even if cache exists (default: false)
  Future<void> fetchHistory({
    required String companyName,
    int? limit,
    bool forceRefresh = false,
  }) async {
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _history.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _historyService.getHistory(
        companyName: companyName,
        limit: limit,
      );
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Error fetching history: $e');
      rethrow;
    }
  }

  /// Add a new classification to history
  /// 
  /// [classification] - Classification data to add
  Future<void> addClassification(Map<String, dynamic> classification) async {
    _history.insert(0, classification);

    // Update cache
    await _historyService.addToCache(classification);

    notifyListeners();
  }

  /// Clear classification history
  Future<void> clearHistory() async {
    _history = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh history from Firestore
  /// 
  /// [companyName] - Company name to filter predictions by (required)
  Future<void> refresh({required String companyName}) async {
    await fetchHistory(companyName: companyName, forceRefresh: true);
  }
}

