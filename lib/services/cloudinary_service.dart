import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static String get _cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get _uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  /// Uploads [bytes] to Cloudinary and returns the secure URL.
  /// [publicId] is used as the file name (no extension needed).
  static Future<String> uploadImage(Uint8List bytes, String publicId) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = 'group_images/$publicId'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: '$publicId.jpg',
      ));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      final error = jsonDecode(body);
      throw Exception(error['error']?['message'] ?? 'Upload failed');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }
}
