import 'dart:io';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageSaverService {
  static Future<void> saveImageToGallery(XFile image) async {
    try {
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
    } on GalException {
      rethrow; // Rethrow the GalException for handling in the UI layer
    } catch (e) {
      throw Exception('An unexpected error occurred during saving: $e');
    }
  }
}