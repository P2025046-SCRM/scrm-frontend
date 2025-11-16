import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/bottom_nav_bar_widget.dart';
import 'package:scrm/data/providers/classification_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/presentation/feedback/feedback_screen.dart';
import 'widgets/history_item_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch history on screen load
      final classificationProvider = Provider.of<ClassificationProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Get company name from user data
      final companyName = userProvider.userCompany ?? '3J Solutions';
      
      if (classificationProvider.history.isEmpty) {
        classificationProvider.fetchHistory(companyName: companyName).catchError((e) {
          print('Failed to fetch history: $e');
        });
      }
    });
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay historial disponible', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Get company name for refresh
              if (!mounted) return;
              final userProvider = Provider.of<UserProvider>(this.context, listen: false);
              final companyName = userProvider.userCompany ?? '3J Solutions';
              await classificationProvider.refresh(companyName: companyName);
            },
            child: ListView(
              children: classificationProvider.history.map((item) {
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
                  } catch (e) {
                    print('Error appending SAS token to image URL: $e');
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
                        classificationProvider.refresh(companyName: companyName);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
