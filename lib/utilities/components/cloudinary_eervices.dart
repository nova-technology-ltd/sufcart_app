import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryServices {
  final Cloudinary cloudinary = Cloudinary.unsignedConfig(
    cloudName: 'dvqs2kxmw',
  );

  // Upload image using unsigned upload
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

  // Pick an image from the gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  }
}