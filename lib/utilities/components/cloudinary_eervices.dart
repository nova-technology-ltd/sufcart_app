// import 'dart:io';
// import 'package:cloudinary/cloudinary.dart';
// import 'package:image_picker/image_picker.dart';
//
// class CloudinaryServices {
//   final Cloudinary cloudinary = Cloudinary.unsignedConfig(
//     cloudName: 'dvqs2kxmw',
//   );
//
//   // Upload image using unsigned upload
//   Future<String?> uploadImage(File imageFile) async {
//     try {
//       final response = await cloudinary.unsignedUpload(
//         file: imageFile.path,
//         uploadPreset: 'Tidmuv_images',
//         resourceType: CloudinaryResourceType.image,
//         progressCallback: (count, total) {
//           print('Uploading image: $count/$total');
//         },
//       );
//
//       if (response.isSuccessful) {
//         print('Image uploaded successfully: ${response.secureUrl}');
//         return response.secureUrl;
//       } else {
//         print('Upload failed: ${response.error}');
//         return null;
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     }
//   }
//
//   // Pick an image from the gallery
//   Future<File?> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       return File(pickedFile.path);
//     } else {
//       print('No image selected.');
//       return null;
//     }
//   }
// }


import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html; // Added for web support

class CloudinaryServices {
  final Cloudinary cloudinary = Cloudinary.unsignedConfig(
    cloudName: 'dvqs2kxmw',
  );

  // Upload image using unsigned upload for mobile (File)
  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await cloudinary.unsignedUpload(
        file: imageFile.path,
        uploadPreset: 'Tidmuv_images',
        resourceType: CloudinaryResourceType.image,
        progressCallback: (count, total) {
          print('Uploading image: $count/$total');
        },
      );

      if (response.isSuccessful) {
        print('Image uploaded successfully: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Upload failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload image using bytes for web
  Future<String?> uploadImageBytes(List<int> bytes, String fileName) async {
    try {
      final response = await cloudinary.unsignedUpload(
        fileBytes: Uint8List.fromList(bytes),
        fileName: fileName,
        uploadPreset: 'Tidmuv_images',
        resourceType: CloudinaryResourceType.image,
        progressCallback: (count, total) {
          print('Uploading image bytes: $count/$total');
        },
      );

      if (response.isSuccessful) {
        print('Image uploaded successfully: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Upload failed: ${response.error}');
        return null;
      }
    } catch (e) {
      print('Error uploading image bytes: $e');
      return null;
    }
  }

  // Pick an image from the gallery (mobile) or file picker (web)
  Future<dynamic> pickImage() async {
    if (kIsWeb) {
      // Web-specific image picking
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();
      await input.onChange.first;
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        return files[0]; // Return html.File for web
      }
      print('No image selected.');
      return null;
    } else {
      // Mobile image picking
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path); // Return File for mobile
      }
      print('No image selected.');
      return null;
    }
  }
}