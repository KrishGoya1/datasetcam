import 'dart:io';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageSaverService {
  static Future<void> saveImageToGallery(
    XFile image, {
    required int setNumber,
    required String type,
  }) async {
    try {
      final fileName = '${setNumber}_$type.png';
      
      if (Platform.isAndroid) {
        final Directory? extDir = await getExternalStorageDirectory();
        if (extDir == null) throw Exception('Could not get external storage directory.');
        final Directory customDir = Directory('${extDir.path}/Pictures/datasetcam');
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }
        final String filePath = path.join(customDir.path, fileName);
        final File savedImage = await File(image.path).copy(filePath);
        await Gal.putImage(savedImage.path);

      } else if (Platform.isIOS) {
        await Gal.putImage(image.path, album: 'datasetcam');
      }
    } on GalException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred during saving: $e');
    }
  }
}