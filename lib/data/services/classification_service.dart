import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scrm/data/models/camera_module/classification_result_model.dart';
import 'package:scrm/data/services/remote_config_service.dart';
import 'package:scrm/utils/logger.dart';

/// Service for image classification operations
/// 
/// Handles communication with the external WasteNet API for image classification
class ClassificationService {
  final RemoteConfigService _remoteConfigService;

  ClassificationService(this._remoteConfigService);

  String get apiBaseUrl => _remoteConfigService.apiBaseUrl;
  String get apiKeyBackend => _remoteConfigService.apiKeyBackend;

  Future<ClassificationResult> classifyImage(String imageBase64) async {

    final payload = {
      "mode": "prod", //prod for real production inference. when testing:
      // "layer1" used to test binary layer only
      // "layer2" used to test multiclass layer only
      "image_base64": imageBase64
    };

    //Create headers
    final headers = {
      'Content-Type': 'application/json',
      'X-API-Key': apiKeyBackend
    };

    final predictionUrl = '$apiBaseUrl/predict';

    //Make POST Request
    try {
      AppLogger.logInfo('ClassificationService: Sending request to $predictionUrl');
      final response = await http.post(
        Uri.parse(predictionUrl),
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

