import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/item_thumbnail_widget.dart';
import 'package:scrm/presentation/camera_module/widgets/action_button_widget.dart';
import 'package:scrm/data/repositories/camera_repository.dart';
import 'package:scrm/data/services/prediction_service.dart';
import 'package:scrm/data/services/history_service.dart';
import 'package:scrm/data/providers/dashboard_provider.dart';
import 'package:scrm/data/providers/user_provider.dart';
import 'package:scrm/utils/waste_type_helper.dart';

class CameraModScreen extends StatefulWidget {
  const CameraModScreen({super.key});

  @override
  State<CameraModScreen> createState() => _CameraModScreenState();
}


class _CameraModScreenState extends State<CameraModScreen> {
  List<CameraDescription> cameras = [];
  CameraController? camController;
  int selectedCameraIndex = 0;
  int isDebug = 1; // 1 for debug, 0 for prod, replace later for provider

  String imagePath = 'assets/sample_wood_image.jpg'; // placeholder imagepath;

  bool isCurrentImageAsset = true; // to check if current img is asset of from gallery/camera

  XFile? imageFile;
  
  // Image to be sent to endpoint
  XFile? imageToProcess;
  bool isProcessing = false;

  final CameraRepository _cameraRepository = CameraRepository();
  PredictionService? _predictionService; // Will be initialized from context
  HistoryService? _historyService; // Will be initialized from context

  //state variables for classification result
  String? layer1; // null if no previous prediction
  String? layer2; // null if no previous prediction
  double? layer1Confidence; // null if no previous prediction
  double? layer2Confidence; // null if no previous prediction
  bool _hasLoadedLatestPrediction = false; // Track if we've attempted to load latest prediction

  @override
  void initState(){
    super.initState();
    _setupCameraController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize services from Provider
    _predictionService = Provider.of<PredictionService>(context, listen: false);
    _historyService = Provider.of<HistoryService>(context, listen: false);
    
    // Load latest prediction if not already loaded
    if (!_hasLoadedLatestPrediction) {
      _loadLatestPrediction();
      _hasLoadedLatestPrediction = true;
    }
  }

  /// Load the latest prediction from Firestore for the current user's company
  Future<void> _loadLatestPrediction() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final companyName = userProvider.userCompany ?? '3J Solutions';
      
      if (_historyService == null) {
        print('HistoryService not available');
        return;
      }

      final latestPrediction = await _historyService!.getLatestPrediction(
        companyName: companyName,
      );

      if (!mounted) return;

      if (latestPrediction != null) {
        // Extract layer1 and layer2 data
        final layer1Result = latestPrediction['layer1_result'] as Map<String, dynamic>?;
        final layer2Result = latestPrediction['layer2_result'] as Map<String, dynamic>?;
        
        // Get image URL and append SAS token if needed
        String latestImagePath = latestPrediction['image_url'] as String? ?? '';
        if (latestImagePath.isNotEmpty && latestImagePath.startsWith('http')) {
          try {
            final sasToken = dotenv.env['AZURE_CONTAINER_SAS_TOKEN'];
            if (sasToken != null && sasToken.isNotEmpty) {
              final separator = latestImagePath.contains('?') ? '&' : '?';
              latestImagePath = '$latestImagePath$separator$sasToken';
            }
          } catch (e) {
            print('Error appending SAS token to image URL: $e');
          }
        }

        setState(() {
          // Update image path
          if (latestImagePath.isNotEmpty) {
            imagePath = latestImagePath;
            isCurrentImageAsset = false; // Network image
          } else {
            // Keep asset image if no image URL
            imagePath = 'assets/sample_wood_image.jpg';
            isCurrentImageAsset = true;
          }

          // Update classification results
          layer1 = layer1Result?['prediction'] as String?;
          layer1Confidence = (layer1Result?['confidence'] as num?)?.toDouble();
          layer2 = layer2Result?['prediction'] as String?;
          layer2Confidence = (layer2Result?['confidence'] as num?)?.toDouble();
        });
      } else {
        // No previous prediction - keep asset image, clear text labels
        setState(() {
          imagePath = 'assets/sample_wood_image.jpg';
          isCurrentImageAsset = true;
          layer1 = null;
          layer2 = null;
          layer1Confidence = null;
          layer2Confidence = null;
        });
      }
    } catch (e) {
      print('Error loading latest prediction: $e');
      // On error, default to asset image with no labels
      if (mounted) {
        setState(() {
          imagePath = 'assets/sample_wood_image.jpg';
          isCurrentImageAsset = true;
          layer1 = null;
          layer2 = null;
          layer1Confidence = null;
          layer2Confidence = null;
        });
      }
    }
  }

  @override
  void dispose() {
    camController?.dispose();
    super.dispose();
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> availableCams = await availableCameras();
    if (availableCams.isNotEmpty) {
      setState(() {
        cameras = availableCams;
        camController = CameraController(
          availableCams[selectedCameraIndex],
          ResolutionPreset.medium,
        );
      });
      camController?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((Object e){
        print(e);
      });
    }
  }

  // Process image from either camera or gallery
  Future<void> _processImage(XFile imageFile) async {
    try {
      setState(() {
        imageToProcess = imageFile;
        imagePath = imageFile.path;

        isCurrentImageAsset = false;
        isProcessing = true;
      });

      final bytes = await imageFile.readAsBytes();
      final String imageBase64 = base64Encode(bytes);
      final classification =
          await _cameraRepository.classifyImage(imageBase64);

      if (!mounted) return;

      setState(() {
        layer1 = classification.layer1Result.prediction;
        layer2 = classification.layer2Result?.prediction ?? 'NN';
        // Always keep layer1 confidence for first-layer result
        layer1Confidence = classification.layer1Result.confidence;
        // Store layer2 confidence separately (may be null if no second layer)
        layer2Confidence = classification.layer2Result?.confidence;
      });

      // Save prediction to Firestore after successful classification
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUser = userProvider.currentUser;
        
        if (currentUser != null && _predictionService != null) {
          // Save prediction document
          await _predictionService!.savePredictionForCurrentUser(
            classificationResult: classification,
            currentUserData: currentUser,
          );
          print('Prediction saved successfully');

          // Refresh dashboard statistics for this company so data is up-to-date when user returns
          final companyName = currentUser['company'] as String? ?? '3J Solutions';
          final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
          await dashboardProvider.refresh(companyName: companyName);
          print('Dashboard statistics refreshed for company: $companyName');
        } else {
          print('Warning: Could not save prediction - user data or prediction service not available');
        }
      } catch (e) {
        // Log error but don't block the UI - prediction display is more important
        print('Error saving prediction to Firestore or refreshing dashboard: $e');
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        await _processImage(pickedFile);
        print('Image picked: $imagePath');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (camController == null || !camController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await camController!.takePicture();
      await _processImage(photo);
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _switchCamera() async {
    if (cameras.isEmpty) return;

    // Dispose current controller
    await camController?.dispose();

    setState(() {
      // Toggle between available cameras
      selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
      
      // Create new controller with selected camera
      camController = CameraController(
        cameras[selectedCameraIndex],
        ResolutionPreset.medium,
      );
    });

    // Initialize new controller
    try {
      await camController?.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double picSize = MediaQuery.sizeOf(context).width;

    // Convert confidences (0.0–1.0) to percentage with one decimal place
    // Only calculate if confidence values exist
    final String? layer1ConfidenceText = layer1Confidence != null 
        ? (layer1Confidence! * 100).toStringAsFixed(1) 
        : null;
    final String? layer2ConfidenceText =
        layer2Confidence != null ? (layer2Confidence! * 100).toStringAsFixed(1) : null;
    // Interno/Externo label based on layer1/layer2 combination (helper as before)
    // Only calculate if both layer1 and layer2 exist
    final String? wasteLabel = (layer1 != null && layer2 != null) 
        ? WasteTypeHelper.getWasteType(layer1!, layer2!) 
        : null;

    return Scaffold(
      appBar: CustomAppbar(title: 'Clasificación de Residuos',
        showProfile: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10,),
            SizedBox(
              width: picSize,
              height: picSize * 4 / 3,
              child: (camController == null || camController?.value.isInitialized == false)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CameraPreview(camController!),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isDebug == 1
                    ? ActionIconButton(onPressed: _pickImageFromGallery, icon: Icons.image_outlined)
                    : SizedBox(width: 48),
                  Text(isProcessing ? "Procesando..." : "Escaneando...", 
                       style: kSubtitleTextStyle),
                  ActionIconButton(onPressed: isProcessing ? null : _takePicture, icon: Icons.camera) //TODO: change for an automatic trigger later
                ],
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  ItemThumbnail(imagePath: imagePath, isAsset: isCurrentImageAsset,),
                  const SizedBox(width: 5,),
                  // Friendly label for layer1
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Only show layer1 result and confidence if data exists
                      if (layer1 != null && layer1ConfidenceText != null)
                        Text(
                          '${layer1 == 'NoReciclable' ? 'No Reciclable' : layer1} • $layer1ConfidenceText%',
                          style: kSubtitleTextStyle,
                        ),
                      // Only show layer2 line (class, Interno/Externo label, and confidence) when layer1 is Reciclable and data exists
                      if (layer1 == 'Reciclable' && 
                          layer2 != null && 
                          layer2!.isNotEmpty && 
                          layer2ConfidenceText != null && 
                          wasteLabel != null) ...[
                        if (layer1 != null && layer1ConfidenceText != null)
                          const SizedBox(height: 10,),
                        Text(
                          '$layer2 • $wasteLabel • $layer2ConfidenceText%',
                          style: kRegularTextStyle,
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  if (cameras.length > 1)
                    ActionIconButton(onPressed: _switchCamera, icon: Icons.cameraswitch_outlined)
                  else
                    const SizedBox(width: 1,),
                  const SizedBox(width: 8,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
