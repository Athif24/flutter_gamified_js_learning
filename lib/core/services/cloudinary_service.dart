import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  static const _cloudName = 'dvq7yobrh';
  static const _uploadPreset = 'ml_default';
  static final _dio = Dio();

  static Future<String> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File gambar tidak ditemukan');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'upload_preset': _uploadPreset,
      });
      final res = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
        data: formData,
      );
      final url = res.data['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Gagal mendapatkan URL gambar dari Cloudinary');
      }
      return url;
    } on DioException {
      throw Exception('Gagal mengunggah gambar. Periksa koneksi internet Anda');
    }
  }
}
