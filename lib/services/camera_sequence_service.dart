import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:datasetcam/services/image_saver.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraSequenceService {
  static const String _counterKey = 'imageCounter';

  static Future<void> takePictureSequence({
    required CameraController controller,
    required void Function(Color?) onColorOverlayStateChanged,
    required BuildContext context,
  }) async {
    // Get the shared preferences instance
    final prefs = await SharedPreferences.getInstance();
    
    // Read the current counter, defaulting to 1 if not found
    int imageCounter = prefs.getInt(_counterKey) ?? 1;

    try {
      // Capture the neutral image
      final neutralImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        neutralImage,
        setNumber: imageCounter,
        type: 'neutral',
      );

      // Capture the red image
      onColorOverlayStateChanged(Colors.red);
      await Future.delayed(const Duration(milliseconds: 500));
      final redImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        redImage,
        setNumber: imageCounter,
        type: 'red',
      );

      // Capture the green image
      onColorOverlayStateChanged(Colors.green);
      await Future.delayed(const Duration(milliseconds: 500));
      final greenImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        greenImage,
        setNumber: imageCounter,
        type: 'green',
      );

      // Capture the blue image
      onColorOverlayStateChanged(Colors.blue);
      await Future.delayed(const Duration(milliseconds: 500));
      final blueImage = await controller.takePicture();
      await ImageSaverService.saveImageToGallery(
        blueImage,
        setNumber: imageCounter,
        type: 'blue',
      );

      // Reset overlay, increment the counter, and save it to persistent storage
      onColorOverlayStateChanged(null);
      imageCounter++;
      await prefs.setInt(_counterKey, imageCounter);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Set ${imageCounter - 1} captured!'),
        ),
      );
    } on GalException catch (e) {
      debugPrint('GalException: ${e.type.message}');
      onColorOverlayStateChanged(null);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.type.message}')),
      );
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
      onColorOverlayStateChanged(null);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
}