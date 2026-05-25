import 'package:dio/dio.dart';

class CloudinaryService {
  static const _cloudName = 'dvq7yobrh';
  static const _uploadPreset = 'ml_default';

  static Future<String> uploadImage(String filePath) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'upload_preset': _uploadPreset,
    });
    final res = await dio.post(
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
      data: formData,
    );
    return res.data['secure_url'] as String;
  }
}
