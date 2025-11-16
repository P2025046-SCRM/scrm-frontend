import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:scrm/data/models/camera_module/classification_result_model.dart';

class CameraRepository {
  //these are set from .env file
  final String? apiBaseUrl = dotenv.env['WFWASTENET_API_BASE_URL'];
  final String? apiBearerToken = dotenv.env['WFWASTENET_API_BEARER_TOKEN'];

  Future<ClassificationResult> classifyImage(String imageBase64) async {

    if (apiBaseUrl == null || apiBearerToken == null){
      throw Exception("API url or token not found in env variables");
    }

    //Create payload
    final payload = {
      "mode": "prod", //prod for real production inference. when testing:
      // "layer1" used to test binary layer only
      // "layer2" used to test multiclass layer only
      // "health" used to test api health
      "image_base64": imageBase64
    };

    //Create headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiBearerToken'
    };

    //Make POST Request
    try {
      final response = await http.post(
        Uri.parse(apiBaseUrl!),
        headers: headers,
        body: json.encode(payload),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw Exception("Empty response body.");
        }
        final Map<String, dynamic> responseJson = json.decode(response.body) as Map<String, dynamic>;
        return ClassificationResult.fromJson(responseJson);
      } else {
        throw Exception("API error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to connect to API: $e");
    }
  }
}