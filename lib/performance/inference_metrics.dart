// performance/inference_metrics.dart
class InferenceMetrics {
  final int totalRuns;
  final int inferenceAvgMs;
  final int inferenceMinMs;
  final int inferenceMaxMs;
  final int inferenceStdDevMs;
  final int preprocessAvgMs;
  final int postprocessAvgMs;
  final List<int> allTimesMs;
  final double fps;

  const InferenceMetrics({
    required this.totalRuns,
    required this.inferenceAvgMs,
    required this.inferenceMinMs,
    required this.inferenceMaxMs,
    required this.inferenceStdDevMs,
    required this.preprocessAvgMs,
    required this.postprocessAvgMs,
    required this.allTimesMs,
    required this.fps,
  });

  factory InferenceMetrics.empty() {
    return InferenceMetrics(
      totalRuns: 0,
      inferenceAvgMs: 0,
      inferenceMinMs: 0,
      inferenceMaxMs: 0,
      inferenceStdDevMs: 0,
      preprocessAvgMs: 0,
      postprocessAvgMs: 0,
      allTimesMs: [],
      fps: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_runs': totalRuns,
      'inference_avg_ms': inferenceAvgMs,
      'inference_min_ms': inferenceMinMs,
      'inference_max_ms': inferenceMaxMs,
      'inference_std_dev_ms': inferenceStdDevMs,
      'preprocess_avg_ms': preprocessAvgMs,
      'postprocess_avg_ms': postprocessAvgMs,
      'all_times_ms': allTimesMs,
      'fps': fps,
      'rating': _getRating(),
    };
  }

  String _getRating() {
    if (inferenceAvgMs < 100) return 'excellent';
    if (inferenceAvgMs < 200) return 'good';
    if (inferenceAvgMs < 300) return 'fair';
    return 'poor';
  }
}