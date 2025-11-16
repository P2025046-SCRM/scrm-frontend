import 'layer_result_model.dart';
import 'metadata_classification_model.dart';

class ClassificationResult {
  final LayerResult layer1Result;
  final LayerResult? layer2Result;
  final ClassificationMetadata? metadata;
  final String? imageUrl; // URL to the processed image

  ClassificationResult({
    required this.layer1Result,
    this.layer2Result,
    this.metadata,
    this.imageUrl,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      layer1Result: LayerResult.fromJson(
        json['layer1_result'] as Map<String, dynamic>,
      ),
      layer2Result: json['layer2_result'] == null
          ? null
          : LayerResult.fromJson(
              json['layer2_result'] as Map<String, dynamic>,
            ),
      metadata: json['metadata'] == null
          ? null
          : ClassificationMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layer1_result': layer1Result.toJson(),
      if (layer2Result != null) 'layer2_result': layer2Result!.toJson(),
      if (metadata != null) 'metadata': metadata!.toJson(),
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
