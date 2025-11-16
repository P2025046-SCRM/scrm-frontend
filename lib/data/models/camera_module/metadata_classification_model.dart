class ClassificationMetadata {
  final DateTime? classificationTimestampUtc;
  final double? totalProcessingTimeSeconds;
  final double? l1InferenceTimeSeconds;
  final double? l2InferenceTimeSeconds;

  ClassificationMetadata({
    this.classificationTimestampUtc,
    this.totalProcessingTimeSeconds,
    this.l1InferenceTimeSeconds,
    this.l2InferenceTimeSeconds,
  });

  factory ClassificationMetadata.fromJson(Map<String, dynamic> json) {
    return ClassificationMetadata(
      classificationTimestampUtc:
          DateTime.tryParse(json['classification_timestamp_utc'] as String? ?? ''),
      totalProcessingTimeSeconds:
          (json['total_processing_time_seconds'] as num?)?.toDouble(),
      l1InferenceTimeSeconds:
          (json['l1_inference_time_seconds'] as num?)?.toDouble(),
      l2InferenceTimeSeconds:
          (json['l2_inference_time_seconds'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (classificationTimestampUtc != null)
        'classification_timestamp_utc':
            classificationTimestampUtc!.toIso8601String(),
      if (totalProcessingTimeSeconds != null)
        'total_processing_time_seconds': totalProcessingTimeSeconds,
      if (l1InferenceTimeSeconds != null)
        'l1_inference_time_seconds': l1InferenceTimeSeconds,
      if (l2InferenceTimeSeconds != null)
        'l2_inference_time_seconds': l2InferenceTimeSeconds,
    };
  }
}
