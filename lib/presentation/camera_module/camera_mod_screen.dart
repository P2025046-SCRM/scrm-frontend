import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/item_thumbnail_widget.dart';
import 'package:scrm/presentation/camera_module/widgets/action_button_widget.dart';

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

  //state variables for classification result
  String layer1 = 'Reciclable';
  String layer2 = 'Retazo de Madera';
  double confidence = 0.95;

  //Random object for simmulating different results
  final _random = Random();

  //Dummy data for simulation
  final List<Map<String, dynamic>> _dummyClassificationData = const [
    {
      'layer1': 'Reciclable',
      'layer2': 'Retazo de Madera',
      'confidence': 0.939,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Pieza Plástica',
      'confidence': 0.888,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Metal',
      'confidence': 0.751,
    },
    {
      'layer1': 'No Reciclable',
      'layer2': 'Contaminado',
      'confidence': 0.962,
    },
    {
      'layer1': 'No Reciclable',
      'layer2': 'Residuo Orgánico',
      'confidence': 0.869,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Biomasa',
      'confidence': 0.778,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Retazo de Madera',
      'confidence': 0.981,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Pieza Plástica',
      'confidence': 0.884,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Metal',
      'confidence': 0.91,
    },
    {
      'layer1': 'Reciclable',
      'layer2': 'Biomasa',
      'confidence': 0.89,
    },
  ];

  @override
  void initState(){
    super.initState();
    _setupCameraController();
  }

  String _wasteType(String layer1, String layer2) {
    String recycleType = '';
    if (layer1 == 'No Reciclable') {
      return layer1;
    } else if (layer1 == 'Reciclable') {
      switch (layer2) {
        case 'Retazo de Madera':
          recycleType = 'Interno';
          break;
        case 'Biomasa':
          recycleType = 'Externo';
          break;
        case 'Metal':
          recycleType = 'Externo';
          break;
        case 'Pieza Plástica':
          recycleType = 'Interno';
          break;
        default:
          recycleType = 'Desconocido'; // Added a default for safety
      }
      return '$layer1 - $recycleType';
    } else {
      return layer1;
    }
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

      // TODO: Once endpoint is implemented, send imageToProcess here
      // For now, simulate processing and results
      await Future.delayed(const Duration(seconds: 1));

      // Simulate new classification results
      final int randomIndex = _random.nextInt(_dummyClassificationData.length);
      final Map<String, dynamic> randomResult = _dummyClassificationData[randomIndex];

      //******************* */
      
      if (mounted) {
        setState(() {
          layer1 = randomResult['layer1'];
          layer2 = randomResult['layer2'];
          confidence = randomResult['confidence'];
          isProcessing = false;
        });
      }

      print('Image ready for processing: ${imageToProcess?.path}');
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

    double showConfidence = (confidence * 100).roundToDouble();
    String shownLabel = _wasteType(layer1, layer2);

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
                  SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ //added results shown logic
                      Text('$shownLabel • $showConfidence%', style: kSubtitleTextStyle,),
                      SizedBox(height: 10,),
                      Text(layer2, style: kRegularTextStyle,),
                    ],
                  ),
                  Spacer(),
                  cameras.length > 1
                    ? ActionIconButton(onPressed: _switchCamera, icon: Icons.cameraswitch_outlined)
                    : SizedBox(width: 1,),
                  SizedBox(width: 8,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
