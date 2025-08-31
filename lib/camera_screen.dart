import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:datasetcam/services/image_saver.dart';
import 'package:datasetcam/widgets/shutter_button.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  double _originalBrightness = 0;

  @override
  void initState() {
    super.initState();
    _setFullBrightness(); // Set brightness when the screen loads

    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
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
    _restoreBrightness(); // Restore brightness when the screen is disposed
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setFullBrightness() async {
    try {
      _originalBrightness = await ScreenBrightness().current;
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (e) {
      debugPrint("Failed to set brightness: $e");
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness().setScreenBrightness(_originalBrightness);
    } catch (e) {
      debugPrint("Failed to restore brightness: $e");
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      await ImageSaverService.saveImageToGallery(image);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to datasetcam folder!')),
      );
    } catch (e) {
      debugPrint('An error occurred during picture capture or saving: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
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
      floatingActionButton: ShutterButton(onPressed: _takePicture),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}