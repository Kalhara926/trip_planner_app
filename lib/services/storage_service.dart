// File: lib/services/storage_service.dart

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

class StorageService {
  // --- Constructor එක නිවැරදි කර ඇත ---
  // API Secret එක client-side unsigned uploads සඳහා අවශ්‍ය නොවේ.
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME']!,
    dotenv.env['CLOUDINARY_API_KEY']!,
    cache: false,
  );

  Future<CloudinaryResponse?> uploadFile({
    required String filePath,
    required Uint8List? fileBytes,
    required String userId,
    required String folder,
    required String resourceType,
  }) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // The default upload preset 'ml_default' is usually unsigned.
      // If you created a different unsigned preset, use its name here.
      const String uploadPreset = 'ml_default';

      CloudinaryFile file;
      if (kIsWeb) {
        file = CloudinaryFile.fromBytesData(
          fileBytes!,
          identifier: fileName,
          folder: '$folder/$userId',
        );
      } else {
        file = CloudinaryFile.fromFile(
          filePath,
          folder: '$folder/$userId',
          publicId: fileName,
        );
      }

      CloudinaryResponse response = await _cloudinary.uploadFile(
        file,
        uploadPreset: uploadPreset, // <-- Unsigned preset is specified here
      );

      if (response.secureUrl.isNotEmpty) {
        print('File uploaded successfully: ${response.secureUrl}');
        return response;
      } else {
        print(
          'Cloudinary upload failed. Please check your upload preset settings.',
        );
        return null;
      }
    } catch (e) {
      print("Exception during file upload: $e");
      return null;
    }
  }
}
