import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StorageMethods {
  final String cloudinaryUrl =
      "https://api.cloudinary.com/v1_1/your-cloud-name/image/upload";
  final String cloudinaryPreset = "your-upload-preset";
  final String cloudinaryDeleteUrl =
      "https://api.cloudinary.com/v1_1/your-cloud-name/image/destroy";

  Future<Map<String, String>> uploadImageToCloudinary(
    Uint8List file,
    String folderName,
  ) async {
    String uniqueId = const Uuid().v1();
    var uri = Uri.parse(cloudinaryUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = cloudinaryPreset;
    request.fields['folder'] = folderName;
    request.fields['public_id'] = uniqueId;

    var multipartFile =
        http.MultipartFile.fromBytes('file', file, filename: '$uniqueId.jpg');
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var jsonResponse = jsonDecode(String.fromCharCodes(responseData));
      return {
        'url': jsonResponse['secure_url'],
        'publicId': jsonResponse['public_id'],
      };
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<void> deleteImageFromCloudinary(String publicId) async {
    var uri = Uri.parse(cloudinaryDeleteUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] =
        cloudinaryPreset; // Assuming the same preset can be used for deletion
    request.fields['public_id'] = publicId;

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to delete image from Cloudinary');
    }
  }
}
