import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  
  // Cloudinary configuration
  final cloudinary = CloudinaryPublic('drdggm1gi', 'flutter_images', cache: false);

  // Pick image with source selection (for mobile)
  Future<XFile?> pickImageWithSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
        return pickedFile;
      }
    } catch (e) {
      print('Pick image error: $e');
    }
    return null;
  }

  // Pick image using image_picker (defaults to gallery)
  Future<XFile?> pickImage() async {
    return await pickImageWithSource(ImageSource.gallery);
  }

  // Compress image for faster upload
  Future<Uint8List> _compressImage(Uint8List data) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(data);
      
      if (image == null) {
        print('Failed to decode image');
        return data;
      }
      
      // Resize if too large (max 1200px width/height)
      if (image.width > 1200 || image.height > 1200) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1200 : null,
          height: image.height > image.width ? 1200 : null,
        );
      }
      
      // Compress as JPEG with quality 85
      List<int> compressed = img.encodeJpg(image, quality: 85);
      
      print('Original size: ${data.length} bytes');
      print('Compressed size: ${compressed.length} bytes');
      print('Compression ratio: ${((1 - compressed.length / data.length) * 100).toStringAsFixed(1)}%');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      print('Compression error: $e');
      return data;
    }
  }

  // Upload image to Cloudinary (works on both web and mobile)
  Future<String?> uploadImageFile(XFile imageFile, String folder) async {
    try {
      print('Starting upload process...');
      
      // Read image bytes
      Uint8List imageData = await imageFile.readAsBytes();
      print('Image data loaded: ${imageData.length} bytes');
      
      // Compress image for faster upload
      Uint8List compressedData = await _compressImage(imageData);
      print('Image compressed successfully');
      
      // Create unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}';
      
      print('Uploading to Cloudinary...');
      
      // Upload to Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          compressedData,
          identifier: fileName,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      print('Upload successful!');
      print('Image URL: ${response.secureUrl}');
      
      return response.secureUrl;
    } catch (e) {
      print('Upload error: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Pick image for profile
Future<XFile?> pickProfileImage() async {
  return await pickImage();
}

// Upload profile image to Cloudinary
Future<String?> uploadProfileImage(XFile imageFile) async {
  return await uploadImageFile(imageFile, 'profiles');
}
}