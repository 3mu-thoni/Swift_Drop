
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static final CloudinaryService _instance =
      CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  CloudinaryPublic get _cloudinary => CloudinaryPublic(
        dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
        dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
        cache: false,
      );

  final _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    final source =
        fromCamera ? ImageSource.camera : ImageSource.gallery;
    return await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
  }

  // Upload image to Cloudinary
  Future<String?> uploadImage({
    required XFile file,
    required String folder,
  }) async {
    try {
      CloudinaryResponse response;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: file.name,
            folder: 'swiftdrop/$folder',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            folder: 'swiftdrop/$folder',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      }

      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  // Pick and upload in one step
  Future<String?> pickAndUpload({
    required String folder,
    bool fromCamera = false,
  }) async {
    final file = await pickImage(fromCamera: fromCamera);
    if (file == null) return null;
    return await uploadImage(file: file, folder: folder);
  }
}