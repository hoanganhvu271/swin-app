class PredictionResult {
  final String label;
  final String id;
  final double confidence;

  PredictionResult({
    required this.label,
    required this.id,
    required this.confidence,
  });
}

class PredictionStorageObject {
  final String imgPath;
  final List<PredictionResult> result;
  final String timestamp;

  PredictionStorageObject({
    required this.imgPath,
    required this.result,
    required this.timestamp
  });
}
