import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:datasetcam/services/image_saver.dart';
import 'package:gal/gal.dart';

class CameraSequenceService {
  static int _imageCounter = 1;
  static const Duration _overlayDelay = Duration(milliseconds: 500); // Delay for overlay to render

  static Future<void> takePictureSequence({
    required CameraController controller,
    required void Function(Color?) onColorOverlayStateChanged,
    required BuildContext context,
  }) async {
    try {
      // 1. Capture the neutral image
      final neutralImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        neutralImage,
        setNumber: _imageCounter,
        type: 'neutral',
      );

      // 2. Capture the red image
      onColorOverlayStateChanged(const Color.fromARGB(255, 255, 17, 0));
      await Future.delayed(_overlayDelay);
      final redImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        redImage,
        setNumber: _imageCounter,
        type: 'red',
      );

      // 3. Capture the green image
      onColorOverlayStateChanged(const Color.fromARGB(255, 0, 255, 8));
      await Future.delayed(_overlayDelay);
      final greenImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        greenImage,
        setNumber: _imageCounter,
        type: 'green',
      );

      // 4. Capture the blue image
      onColorOverlayStateChanged(const Color.fromARGB(255, 0, 140, 255));
      await Future.delayed(_overlayDelay);
      final blueImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        blueImage,
        setNumber: _imageCounter,
        type: 'blue',
      );

      // 5. Reset overlay and increment counter
      onColorOverlayStateChanged(null); // No overlay
      _imageCounter++;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set ${_imageCounter - 1} captured (neutral, red, green, blue)!'),
        ),
      );
    } on GalException catch (e) {
      debugPrint('GalException: ${e.type.message}');
      onColorOverlayStateChanged(null); // Ensure overlay is removed on error
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.type.message}')),
      );
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      onColorOverlayStateChanged(null); // Ensure overlay is removed on error
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
}