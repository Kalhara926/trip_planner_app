// File: lib/services/storage_service.dart

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'
    show Uint8List; // Web සඳහා අවශ්‍ය Uint8List import කිරීම

class StorageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME']!,
    dotenv.env['CLOUDINARY_API_KEY']!,
    cache: false,
  );

  /// Mobile උපාංග සඳහා File path එකකින් ඡායාරූපය upload කිරීම.
  Future<String?> uploadTripImageFromFile(File imageFile, String userId) async {
    try {
      CloudinaryFile file = await CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'trip_images/$userId',
      );

      CloudinaryResponse response = await _cloudinary.uploadFile(file);

      if (response.statusCode == 200 && response.secureUrl.isNotEmpty) {
        return response.secureUrl;
      } else {
        print(
          "Cloudinary upload failed with status code: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("Error uploading image from file: $e");
      return null;
    }
  }

  /// Web සඳහා image data (Bytes) වලින් ඡායාරූපය upload කිරීම.
  Future<String?> uploadTripImageFromBytes(
    Uint8List imageBytes,
    String userId,
  ) async {
    try {
      CloudinaryFile file = await CloudinaryFile.fromBytesData(
        imageBytes,
        folder: 'trip_images/$userId',
        identifier: '',
      );

      CloudinaryResponse response = await _cloudinary.uploadFile(file);

      if (response.statusCode == 200 && response.secureUrl.isNotEmpty) {
        return response.secureUrl;
      } else {
        print(
          "Cloudinary upload failed with status code: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("Error uploading image from bytes: $e");
      return null;
    }
  }
}

extension on CloudinaryResponse {
  get statusCode => null;
}
