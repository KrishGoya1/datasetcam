// A complete Flutter app that uses the front camera to take a picture and save it to a custom folder.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

List<CameraDescription> cameras = [];

Future<void> main() async {
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

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    // Find the first front-facing camera in the list
    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first, // Fallback to the first camera if no front camera is found
    );

    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          isCameraReady = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();
      String customPath;

      if (Platform.isAndroid) {
        // On Android, save the file to a custom directory and then save that file to the gallery
        final Directory? extDir = await getExternalStorageDirectory();
        if (extDir == null) throw Exception('Could not get external storage directory.');
        final Directory customDir = Directory('${extDir.path}/Pictures/datasetcam');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }
        final String filePath = path.join(customDir.path, path.basename(image.path));
        final File savedImage = await File(image.path).copy(filePath);
        await Gal.putImage(savedImage.path);

      } else if (Platform.isIOS) {
        // On iOS, save the image directly to a custom album
        await Gal.putImage(image.path, album: 'datasetcam');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to datasetcam folder!')),
      );

    } on GalException catch (e) {
      debugPrint('GalException: ${e.type.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.type.message}')),
      );
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Camera'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
