import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// This service is only for local image storage. Student data is managed by SQLiteService.
class LocalStorageService {
  static Future<String> saveImage(File imageFile, String fileName) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'student_images');
      
      // Create the directory if it doesn't exist
      await Directory(imagesDir).create(recursive: true);
      
      // Create a unique filename
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final String savedPath = path.join(imagesDir, uniqueFileName);
      
      // Copy the image file to the new location
      await imageFile.copy(savedPath);
      
      return savedPath;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  static Future<File?> getImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }
} 