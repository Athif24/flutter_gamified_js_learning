import 'package:dio/dio.dart';

class CloudinaryService {
  static const String _cloudName = 'dvq7yobrh';
  static const String _uploadPreset = 'ml_default';

  static Future<String> uploadImage(String filePath) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'upload_preset': _uploadPreset,
    });

    final response = await dio.post(
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
      data: formData,
    );

    return response.data['secure_url'] as String;
  }
}
