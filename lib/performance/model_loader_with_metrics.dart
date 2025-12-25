// performance/model_loader_with_metrics.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

import 'device_info.dart';

class ModelLoaderWithMetrics {
  late OrtSession _session;
  final OrtEnv _env = OrtEnv.instance;

  // Metrics storage
  int _modelLoadingTimeMs = 0;
  int _modelSizeBytes = 0;
  DateTime? _modelLoadedAt;

  /// Load model với đo thời gian chi tiết
  Future<OrtSession> loadModelWithTiming({
    required Uint8List modelBytes,
    bool enableOptimizations = true,
    bool logToConsole = true,
  }) async {
    final stopwatch = Stopwatch();
    final metrics = <String, int>{};

    // Tổng thời gian
    stopwatch.start();

    // 1. Khởi tạo session options
    final optionsStopwatch = Stopwatch()..start();
    final OrtSessionOptions options = OrtSessionOptions();
    optionsStopwatch.stop();
    metrics['options_init_ms'] = optionsStopwatch.elapsedMilliseconds;

    // 2. Tạo session từ bytes
    final sessionStopwatch = Stopwatch()..start();
    _session = OrtSession.fromBuffer(modelBytes, options);
    sessionStopwatch.stop();
    metrics['session_create_ms'] = sessionStopwatch.elapsedMilliseconds;

    stopwatch.stop();

    // Lưu metrics
    _modelLoadingTimeMs = stopwatch.elapsedMilliseconds;
    _modelSizeBytes = modelBytes.length;
    _modelLoadedAt = DateTime.now();

    // Log kết quả
    if (logToConsole) {
      _printLoadingReport(metrics, modelBytes.length);
    }

    // Lưu metrics vào file (tùy chọn)
    await _saveLoadingMetrics(metrics);

    return _session;
  }

  void _printLoadingReport(Map<String, int> metrics, int modelSize) {
    print('''
📦 ========== MODEL LOADING REPORT ==========
📊 Model Size: ${modelSize ~/ 1024} KB
⏱️  Total Loading Time: ${_modelLoadingTimeMs}ms
├── Options Initialization: ${metrics['options_init_ms']}ms
└── Session Creation: ${metrics['session_create_ms']}ms
💾 Memory Usage: ~${(modelSize ~/ 1024) + 50} KB (estimated)
============================================
''');
  }

  Future<void> _saveLoadingMetrics(Map<String, int> metrics) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/model_loading_metrics.json');

      final data = {
        'model_loading_time_ms': _modelLoadingTimeMs,
        'model_size_bytes': _modelSizeBytes,
        'metrics': metrics,
        'timestamp': DateTime.now().toIso8601String(),
        'device_info': await getDeviceInfo(),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('⚠️ Could not save loading metrics: $e');
    }
  }

  // Getters
  int get loadingTimeMs => _modelLoadingTimeMs;
  int get modelSizeKB => _modelSizeBytes ~/ 1024;
  DateTime? get loadedAt => _modelLoadedAt;

  void close() {
    try {
      _session.release();
    } catch (_) {}
    _env.release();
  }
}