import 'dart:io';
import 'package:uuid/uuid.dart';
import '../config/constants.dart';
import 'supabase_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  final _supabase = SupabaseService.instance.client;
  final _uuid = const Uuid();

  // Upload location image
  Future<String> uploadLocationImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final path = 'locations/$fileName';

      await _supabase.storage
          .from(AppConstants.locationImagesBucket)
          .upload(path, imageFile);

      final publicUrl = _supabase.storage
          .from(AppConstants.locationImagesBucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload location image: $e');
    }
  }

  // Upload multiple location images
  Future<List<String>> uploadLocationImages(List<File> imageFiles) async {
    final List<String> urls = [];
    
    for (final file in imageFiles) {
      try {
        final url = await uploadLocationImage(file);
        urls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
        // Continue with other images even if one fails
      }
    }
    
    return urls;
  }

  // Upload review image
  Future<String> uploadReviewImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final path = 'reviews/$fileName';

      await _supabase.storage
          .from(AppConstants.reviewImagesBucket)
          .upload(path, imageFile);

      final publicUrl = _supabase.storage
          .from(AppConstants.reviewImagesBucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload review image: $e');
    }
  }

  // Upload multiple review images
  Future<List<String>> uploadReviewImages(List<File> imageFiles) async {
    final List<String> urls = [];
    
    for (final file in imageFiles) {
      try {
        final url = await uploadReviewImage(file);
        urls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    
    return urls;
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName = '$userId.jpg';
      final path = 'profiles/$fileName';

      // Delete old profile image if exists
      try {
        await _supabase.storage
            .from(AppConstants.profileImagesBucket)
            .remove([path]);
      } catch (e) {
        // Ignore if file doesn't exist
      }

      await _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .upload(path, imageFile);

      final publicUrl = _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete location images
  Future<void> deleteLocationImages(List<String> imageUrls) async {
    try {
      final paths = imageUrls
          .map((url) => _extractPathFromUrl(url, AppConstants.locationImagesBucket))
          .where((path) => path != null)
          .cast<String>()
          .toList();

      if (paths.isNotEmpty) {
        await _supabase.storage
            .from(AppConstants.locationImagesBucket)
            .remove(paths);
      }
    } catch (e) {
      print('Error deleting location images: $e');
    }
  }

  // Delete review images
  Future<void> deleteReviewImages(List<String> imageUrls) async {
    try {
      final paths = imageUrls
          .map((url) => _extractPathFromUrl(url, AppConstants.reviewImagesBucket))
          .where((path) => path != null)
          .cast<String>()
          .toList();

      if (paths.isNotEmpty) {
        await _supabase.storage
            .from(AppConstants.reviewImagesBucket)
            .remove(paths);
      }
    } catch (e) {
      print('Error deleting review images: $e');
    }
  }

  // Helper method to extract path from public URL
  String? _extractPathFromUrl(String url, String bucket) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucket);
      
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        return segments.sublist(bucketIndex + 1).join('/');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get image file size
  Future<int> getFileSize(File file) async {
    return await file.length();
  }

  // Validate image size
  bool isValidImageSize(File file, int maxSize) {
    final fileSize = file.lengthSync();
    return fileSize <= maxSize;
  }
}