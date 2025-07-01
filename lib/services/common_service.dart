import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ysyw/global/dio.dart';
import '../config/debug/debug.dart';

class CommonService {
  static final CommonService _instance = CommonService._internal();
  factory CommonService() => _instance;
  CommonService._internal();

  final DioClient _dioClient = DioClient();
  final String _cloudEndPoint = "/cloud/upload-image";

  /// Upload image to Cloudinary and return the URL
  Future<String> uploadImage({
    required String filePath,
    String? fileName,
  }) async {
    final accessToken = dotenv.env['ACCESS_TOKEN'] ?? '';
    Debug.info("Access Token: $accessToken");

    try {
      Debug.api('Uploading image to Cloudinary: $filePath');

      // Create form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('/').last,
        ),
      });
      _dioClient.setHeaders({
        'access_token': accessToken,
        'Content-Type': 'multipart/form-data',
      });

      // Make the request with access token in headers
      final response = await _dioClient.post(
        _cloudEndPoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final String imageUrl = response.data['url'];
        Debug.success('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        Debug.error('Image upload failed with status: ${response.statusCode}');
        throw CommonException('Failed to upload image');
      }
    } on DioException catch (e) {
      Debug.error('Image upload API error: ${e.response?.data ?? e.message}');
      throw CommonException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected image upload error: $e');
      throw CommonException(
          'An unexpected error occurred while uploading image');
    }
  }

  /// Upload image from bytes (useful for picked images)
  Future<String> uploadImageFromBytes({
    required List<int> imageBytes,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final accessToken = dotenv.env['ACCESS_TOKEN'] ?? '';
      Debug.api('Uploading image from bytes: $fileName');

      // Create form data from bytes
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('image', 'jpeg'),
        ),
      });
      _dioClient.setHeaders({
        'access_token': accessToken,
        'Content-Type': 'multipart/form-data',
      });

      // Make the request with access token in headers
      final response = await _dioClient.post(
        _cloudEndPoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final String imageUrl = response.data['url'];
        Debug.success('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        Debug.error('Image upload failed with status: ${response.statusCode}');
        throw CommonException('Failed to upload image');
      }
    } on DioException catch (e) {
      Debug.error('Image upload API error: ${e.response?.data ?? e.message}');
      throw CommonException(_handleDioError(e));
    } catch (e) {
      Debug.error('Unexpected image upload error: $e');
      throw CommonException(
          'An unexpected error occurred while uploading image');
    }
  }

  /// Helper method to validate image file
  bool isValidImageFile(String filePath) {
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = filePath.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Helper method to get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final size = await file.length();
      return size;
    } catch (e) {
      throw CommonException('Unable to get file size');
    }
  }

  /// Helper method to validate file size (in bytes)
  bool isValidFileSize(int fileSize, {int maxSizeInMB = 5}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  /// Upload image with validation
  Future<String> uploadImageWithValidation({
    required String filePath,
    String? fileName,
    int maxSizeInMB = 5,
  }) async {
    try {
      // Validate file extension
      if (!isValidImageFile(filePath)) {
        throw CommonException(
            'Invalid image format. Allowed formats: jpg, jpeg, png, gif, webp');
      }

      // Validate file size
      final fileSize = await getFileSize(filePath);
      if (!isValidFileSize(fileSize, maxSizeInMB: maxSizeInMB)) {
        throw CommonException(
            'File size too large. Maximum size: ${maxSizeInMB}MB');
      }

      Debug.info(
          'File validation passed. Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      // Upload the image
      return await uploadImage(
        filePath: filePath,
        fileName: fileName,
      );
    } catch (e) {
      if (e is CommonException) {
        rethrow;
      }
      throw CommonException('Failed to upload image: $e');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<String> filePaths,
    required String accessToken,
    int maxSizeInMB = 5,
  }) async {
    try {
      Debug.api('Uploading ${filePaths.length} images');

      final List<String> imageUrls = [];

      for (int i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        Debug.info('Uploading image ${i + 1}/${filePaths.length}: $filePath');

        final imageUrl = await uploadImageWithValidation(
          filePath: filePath,
          maxSizeInMB: maxSizeInMB,
        );

        imageUrls.add(imageUrl);
      }

      Debug.success('All ${filePaths.length} images uploaded successfully');
      return imageUrls;
    } catch (e) {
      Debug.error('Multiple image upload failed: $e');
      throw CommonException('Failed to upload multiple images: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 403:
            return 'Unauthorized: Invalid access token.';
          case 400:
            return e.response?.data['error'] ?? 'Bad request.';
          case 500:
            return 'Server error occurred while uploading image.';
          default:
            return e.response?.data['error'] ?? 'Upload failed.';
        }
      case DioExceptionType.cancel:
        return 'Upload was cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred during upload.';
    }
  }
}

class CommonException implements Exception {
  final String message;

  CommonException(this.message);

  @override
  String toString() => 'CommonException: $message';
}
