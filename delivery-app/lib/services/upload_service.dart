import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../providers/order_provider.dart' show apiServiceProvider;

/// Upload service provider
final uploadServiceProvider = Provider<UploadService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UploadService(apiService);
});

class UploadService {
  final ApiService _apiService;

  UploadService(this._apiService);

  /// Upload image file
  Future<String> uploadImage(File file) async {
    try {
      // Prepare multipart request
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Upload to server
      final response = await _apiService.post(
        '/upload/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final imageUrl = response.data['data']['url'] as String;
        return imageUrl;
      } else {
        throw Exception(response.data['message'] ?? 'فشل رفع الصورة');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('حدث خطأ أثناء رفع الصورة');
    } catch (e) {
      throw Exception('حدث خطأ أثناء رفع الصورة');
    }
  }

  /// Update driver documents
  Future<bool> updateDocuments(Map<String, String> documents) async {
    try {
      final response = await _apiService.put(
        '/drivers/documents',
        data: documents,
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('فشل تحديث المستندات');
    } catch (e) {
      throw Exception('فشل تحديث المستندات');
    }
  }
}
