import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:datasetcam/services/camera_sequence_service.dart';
import 'package:datasetcam/widgets/shutter_button.dart';

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
  bool _isRedOverlayActive = false;

  @override
  void initState() {
    super.initState();
    _setFullBrightness();

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
    _restoreBrightness();
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

  void _onOverlayStateChanged(bool value) {
    if (!mounted) return;
    setState(() {
      _isRedOverlayActive = value;
    });
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
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (_isRedOverlayActive)
            Container(
              color: Colors.red.withOpacity(1.0),
            ),
        ],
      ),
      floatingActionButton: ShutterButton(
        onPressed: () => CameraSequenceService.takePictureSequence(
          controller: _controller,
          onOverlayStateChanged: _onOverlayStateChanged,
          context: context,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}