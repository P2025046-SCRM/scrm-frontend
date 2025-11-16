class LayerResult {
  final String model;
  final String prediction;
  final double confidence;
  final List<double>? rawScore; // Only present for layer2, null for layer1

  LayerResult({
    required this.model,
    required this.prediction,
    required this.confidence,
    this.rawScore, // Optional: only layer2 has this field
  });

  factory LayerResult.fromJson(Map<String, dynamic> json) {
    // Parse raw_score if present (layer2 only)
    List<double>? rawScore;
    if (json['raw_score'] != null) {
      final rawScoreList = json['raw_score'] as List<dynamic>;
      rawScore = rawScoreList.map((e) => (e as num).toDouble()).toList();
    }

    return LayerResult(
      model: json['model'] as String? ?? '',
      prediction: json['prediction'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      rawScore: rawScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'prediction': prediction,
      'confidence': confidence,
      if (rawScore != null) 'raw_score': rawScore,
    };
  }
}