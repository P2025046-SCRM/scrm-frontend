import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/bottom_nav_bar_widget.dart';
import 'package:scrm/data/providers/classification_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/logger.dart';
import 'package:scrm/presentation/feedback/feedback_screen.dart';
import 'widgets/history_item_widget.dart';
import 'widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always fetch fresh data to set up pagination properly
      final classificationProvider = Provider.of<ClassificationProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Get company name from user data
      final companyName = userProvider.userCompany ?? '3J Solutions';
      
      // Always fetch fresh data to ensure pagination works
      // If cached history exists, it will be shown immediately, but we still need fresh data for pagination
      classificationProvider.fetchHistory(
        companyName: companyName,
        limit: _pageSize,
        forceRefresh: false, // Don't force refresh on initial load, but still fetch if pagination not set up
      ).catchError((e, stackTrace) {
        AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to fetch history');
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200; // Trigger when 200 pixels from bottom
    
    // Only trigger if we're near the bottom and not already at the bottom
    if (maxScroll > 0 && currentScroll >= (maxScroll - delta)) {
      // Load more when user is 200 pixels from bottom
      _loadMore();
    }
  }

  void _loadMore() {
    final classificationProvider = Provider.of<ClassificationProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!classificationProvider.isLoadingMore &&
        classificationProvider.hasMore) {
      final companyName = userProvider.userCompany ?? '3J Solutions';
      classificationProvider.loadMore(
        companyName: companyName,
        limit: _pageSize,
      ).catchError((e, stackTrace) {
        AppLogger.logError(e, stackTrace: stackTrace, reason: 'Failed to load more history');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Historial de Residuos', showProfile: true),
      body: Consumer<ClassificationProvider>(
        builder: (context, classificationProvider, _) {
          if (classificationProvider.isLoading && classificationProvider.history.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (classificationProvider.history.isEmpty) {
            return const EmptyStateWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Get company name for refresh
              if (!mounted) return;
              final userProvider = Provider.of<UserProvider>(this.context, listen: false);
              final companyName = userProvider.userCompany ?? '3J Solutions';
              // Force refresh to reset pagination and get fresh data
              await classificationProvider.fetchHistory(
                companyName: companyName,
                limit: _pageSize,
                forceRefresh: true,
              );
            },
            child: ListView(
              controller: _scrollController,
              children: [
                ...classificationProvider.history.map((item) {
                // Get prediction ID
                final predictionId = item['id'] as String? ?? '';
                
                // Map Firestore prediction data to widget format
                String imagePath = item['image_path'] as String? ?? 
                                  item['image_url'] as String? ?? 
                                  '';
                
                // Determine if image is asset before appending SAS token
                final bool isAssetImage = imagePath.isEmpty || 
                                         (!imagePath.startsWith('http') && !imagePath.startsWith('/'));
                
                // Append Azure SAS token to image URL if it's a network URL
                if (imagePath.isNotEmpty && imagePath.startsWith('http')) {
                  try {
                    final sasToken = dotenv.env['AZURE_CONTAINER_SAS_TOKEN'];
                    if (sasToken != null && sasToken.isNotEmpty) {
                      // Check if URL already has query parameters
                      final separator = imagePath.contains('?') ? '&' : '?';
                      imagePath = '$imagePath$separator$sasToken';
                    }
                  } catch (e, stackTrace) {
                    AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error appending SAS token to image URL');
                  }
                }
                
                // Extract layer1 and layer2 from model_response
                final layer1Result = item['layer1_result'] as Map<String, dynamic>?;
                final layer2Result = item['layer2_result'] as Map<String, dynamic>?;
                
                final layer1 = layer1Result?['prediction'] as String? ?? 'Unknown';
                final layer2 = layer2Result?['prediction'] as String?;
                
                // Get separate confidences for layer1 and layer2
                final layer1Confidence = (layer1Result?['confidence'] as num?)?.toDouble() ?? 0.0;
                final layer2Confidence = (layer2Result?['confidence'] as num?)?.toDouble();
                
                // Use created_at timestamp from Firestore document
                final timestamp = item['created_at_timestamp'] as String? ?? 
                                 item['timestamp'] as String? ?? 
                                 '';

                // Format timestamp - convert from UTC to device local timezone
                String formattedTime = timestamp;
                if (timestamp.isNotEmpty) {
                  try {
                    // Parse as UTC (Firestore timestamps are UTC)
                    final dateTimeUtc = DateTime.parse(timestamp);
                    // Convert to device local timezone
                    final dateTimeLocal = dateTimeUtc.toLocal();
                    formattedTime = '${dateTimeLocal.day}/${dateTimeLocal.month}/${dateTimeLocal.year} ${dateTimeLocal.hour.toString().padLeft(2, '0')}:${dateTimeLocal.minute.toString().padLeft(2, '0')}';
                  } catch (e) {
                    formattedTime = timestamp;
                  }
                }

                return HistoryListItem(
                  predictionId: predictionId,
                  imagePath: imagePath,
                  layer1: layer1,
                  layer2: layer2 ?? '',
                  classifTime: formattedTime,
                  layer1Confidence: layer1Confidence,
                  layer2Confidence: layer2Confidence,
                  onTap: () {
                    // Navigate to feedback screen
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackScreen(
                          predictionId: predictionId,
                          imagePath: imagePath,
                          isAssetImage: isAssetImage,
                          layer1: layer1,
                          layer2: layer2,
                          layer1Confidence: layer1Confidence,
                          layer2Confidence: layer2Confidence,
                        ),
                      ),
                    ).then((feedbackSaved) {
                      // Refresh history if feedback was saved
                      if (feedbackSaved == true && mounted) {
                        final userProvider = Provider.of<UserProvider>(this.context, listen: false);
                        final companyName = userProvider.userCompany ?? '3J Solutions';
                        // Force refresh to get updated data
                        classificationProvider.fetchHistory(
                          companyName: companyName,
                          limit: _pageSize,
                          forceRefresh: true,
                        );
                      }
                    });
                  },
                );
                }),
                // Show loading indicator at bottom when loading more
                if (classificationProvider.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                // Show message when no more items
                if (!classificationProvider.hasMore && classificationProvider.history.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No hay más elementos',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
