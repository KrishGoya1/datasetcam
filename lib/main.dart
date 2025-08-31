import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:datasetcam/camera_screen.dart';
import 'package:screen_brightness/screen_brightness.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  // Add `screen_brightness: ^2.0.0` to your `pubspec.yaml`
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error: ${e.code}\nError Message: ${e.description}');
  }

  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dataset Camera',
      theme: ThemeData.dark(),
      home: CameraScreen(cameras: cameras),
    );
  }
}