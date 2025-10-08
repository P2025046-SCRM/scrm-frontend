import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/item_thumbnail_widget.dart';

class CameraModScreen extends StatefulWidget {
  const CameraModScreen({super.key});

  @override
  State<CameraModScreen> createState() => _CameraModScreenState();
}

class _CameraModScreenState extends State<CameraModScreen> {
  List<CameraDescription> cameras = [];
  CameraController? camController;
  int selectedCameraIndex = 0;

  XFile? imageFile;
  String? imagePath;

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
          ResolutionPreset.high,
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
        ResolutionPreset.high,
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
      floatingActionButton: cameras.length > 1
          ? FloatingActionButton(
              onPressed: _switchCamera,
              child: const Icon(Icons.switch_camera),
            )
          : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Escaneando...", style: kSubtitleTextStyle,),
              ],
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}