import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:datasetcam/services/image_saver.dart';
import 'package:gal/gal.dart';

class CameraSequenceService {
  static int _imageCounter = 1;

  static Future<void> takePictureSequence({
    required CameraController controller,
    required void Function(bool) onOverlayStateChanged,
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

      // 2. Tell the UI to turn the screen red
      onOverlayStateChanged(true);

      // 3. Wait for the UI to update, then capture the red image
      await Future.delayed(const Duration(milliseconds: 500));
      final redImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        redImage,
        setNumber: _imageCounter,
        type: 'red',
      );

      // 4. Tell the UI to hide the red overlay and increment the counter
      onOverlayStateChanged(false);
      _imageCounter++;

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set $_imageCounter captured!'),
        ),
      );
    } on GalException catch (e) {
      debugPrint('GalException: ${e.type.message}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.type.message}')),
      );
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
}