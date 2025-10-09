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

  XFile? imageFile;
  String? imagePath;
  
  // Image to be sent to endpoint
  XFile? imageToProcess;
  bool isProcessing = false;

  @override
  void initState(){
    super.initState();
    _setupCameraController();
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
        isProcessing = true;
      });

      // TODO: Once endpoint is implemented, send imageToProcess here
      // For now, simulate processing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
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
  }  Future<void> _switchCamera() async {
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
                  ItemThumbnail(imagePath: 'assets/sample_wood_image.jpg',),
                  SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reciclable - Interno • 95.0%', style: kRegularTextStyle,),
                      SizedBox(height: 10,),
                      Text('Retazo de Madera', style: kSubtitleTextStyle,),
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
