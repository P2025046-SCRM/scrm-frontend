import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String? _errorMessage;

  ClassificationProvider(this._historyService) {
    _loadCachedHistory();
  }

  /// Get classification history
  List<Map<String, dynamic>> get history => _history;

  /// Check if history is loading (initial load)
  bool get isLoading => _isLoading;

  /// Check if more items are being loaded (pagination)
  bool get isLoadingMore => _isLoadingMore;

  /// Check if there are more items to load
  bool get hasMore => _hasMore;

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
    _hasMore = true;
    _lastDocument = null;
    notifyListeners();

    try {
      final history = await _historyService.getHistory(
        companyName: companyName,
        limit: limit,
      );
      
      // Extract document snapshots and remove them from history items
      _history = history.map((item) {
        final itemCopy = Map<String, dynamic>.from(item);
        itemCopy.remove('_document_snapshot');
        return itemCopy;
      }).toList();
      
      // Set last document for pagination (last item in the list)
      if (history.isNotEmpty) {
        _lastDocument = history.last['_document_snapshot'] as DocumentSnapshot?;
      } else {
        _lastDocument = null;
      }
      
      // Check if there are more items to load
      final fetchLimit = limit ?? 10;
      _hasMore = history.length == fetchLimit;
      
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

  /// Load more history items (pagination)
  /// 
  /// [companyName] - Company name to filter predictions by (required)
  /// [limit] - Number of records to fetch (default: 10)
  Future<void> loadMore({
    required String companyName,
    int limit = 10,
  }) async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) {
      return;
    }

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = await _historyService.getHistory(
        companyName: companyName,
        limit: limit,
        startAfter: _lastDocument,
      );
      
      if (history.isEmpty) {
        _hasMore = false;
        _isLoadingMore = false;
        notifyListeners();
        return;
      }
      
      // Extract document snapshots and remove them from history items
      final newItems = history.map((item) {
        final itemCopy = Map<String, dynamic>.from(item);
        itemCopy.remove('_document_snapshot');
        return itemCopy;
      }).toList();
      
      _history.addAll(newItems);
      
      // Set last document for pagination (last item in the list)
      if (history.isNotEmpty) {
        _lastDocument = history.last['_document_snapshot'] as DocumentSnapshot?;
      } else {
        _lastDocument = null;
      }
      
      // Check if there are more items to load
      _hasMore = history.length == limit;
      
      _isLoadingMore = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Error loading more history: $e');
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
    _lastDocument = null;
    _hasMore = true;
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
    await fetchHistory(companyName: companyName, limit: 10, forceRefresh: true);
  }
}

