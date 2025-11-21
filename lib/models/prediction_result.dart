class PredictionResult {
  final String label;
  final int index;
  final double confidence;

  PredictionResult({
    required this.label,
    required this.index,
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
