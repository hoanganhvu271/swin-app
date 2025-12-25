// performance/inference_tester.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

import 'device_info.dart';
import 'inference_metrics.dart';

class InferenceTester {
  final OrtSession session;
  final Uint8List testImageBytes;

  List<int> _inferenceTimesMs = [];
  List<int> _preprocessTimesMs = [];
  List<int> _postprocessTimesMs = [];

  InferenceTester({required this.session, required this.testImageBytes});

  /// Chuẩn bị input tensor (cùng logic với OnnxPredictor)
  Future<Map<String, OrtValue>> _prepareInput() async {
    final preprocessStopwatch = Stopwatch()..start();

    // 1. Decode ảnh
    final image = img.decodeImage(testImageBytes)!;

    // 2. Resize về 224x224
    final resized = img.copyResize(image, width: 224, height: 224);

    // 3. Tạo tensor (1, 3, 224, 224)
    final input = Float32List(1 * 3 * 224 * 224);
    int index = 0;

    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);

          double value;
          if (c == 0) {
            value = pixel.r / 255.0;
          } else if (c == 1) {
            value = pixel.g / 255.0;
          } else {
            value = pixel.b / 255.0;
          }

          input[index++] = value; // Không chuẩn hóa để đơn giản hóa test
        }
      }
    }

    // 4. Tạo OrtValueTensor
    final inputTensor = OrtValueTensor.createTensorWithDataList(input, [
      1,
      3,
      224,
      224,
    ]);

    preprocessStopwatch.stop();
    _preprocessTimesMs.add(preprocessStopwatch.elapsedMilliseconds);

    return {'images': inputTensor};
  }

  /// Thực hiện warmup inference
  Future<void> performWarmup({int runs = 3}) async {
    print('🔥 Starting warmup ($runs runs)...');

    final testInput = await _prepareInput();
    final runOptions = OrtRunOptions();

    for (int i = 0; i < runs; i++) {
      final stopwatch = Stopwatch()..start();
      await session.runAsync(runOptions, testInput);
      stopwatch.stop();

      print('  Warmup ${i + 1}: ${stopwatch.elapsedMilliseconds}ms');

      // Nghỉ giữa các lần chạy
      if (i < runs - 1) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    print('✅ Warmup completed\n');
  }

  /// Thực hiện đo inference time
  Future<InferenceMetrics> performMeasurement({int runs = 10}) async {
    print('📊 Starting inference measurement ($runs runs)...');

    _inferenceTimesMs.clear();

    // Chuẩn bị input 1 lần duy nhất để test công bằng
    final testInput = await _prepareInput();
    final runOptions = OrtRunOptions();

    for (int i = 0; i < runs; i++) {
      final stopwatch = Stopwatch()..start();

      // Inference (giống logic trong OnnxPredictor)
      final dynamic asyncResults = await session.runAsync(
        runOptions,
        testInput,
      );

      // Post-processing
      final postprocessStopwatch = Stopwatch()..start();

      // Tìm OrtValue đầu tiên trong cấu trúc trả về
      OrtValue? firstOrt;
      if (asyncResults is List && asyncResults.isNotEmpty) {
        final firstContainer = asyncResults[0];
        if (firstContainer is List && firstContainer.isNotEmpty) {
          firstOrt = firstContainer[0] as OrtValue?;
        } else if (firstContainer is OrtValue) {
          firstOrt = firstContainer as OrtValue?;
        }
      }

      if (firstOrt == null) {
        throw Exception('No output from runAsync');
      }

      // Chuyển đổi kết quả (chỉ để đảm bảo xử lý đầy đủ)
      final dynamic raw = firstOrt.value;
      List<double> outputList;

      if (raw is Float32List) {
        outputList = raw.map((e) => e.toDouble()).toList();
      } else if (raw is List<double>) {
        outputList = List<double>.from(raw);
      } else if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is List) {
          outputList = first.map((e) => (e as num).toDouble()).toList();
        } else if (first is num) {
          outputList = raw.map((e) => (e as num).toDouble()).toList();
        } else {
          outputList = [];
        }
      } else {
        outputList = [];
      }

      postprocessStopwatch.stop();
      stopwatch.stop();

      // Lưu kết quả
      _inferenceTimesMs.add(stopwatch.elapsedMilliseconds);
      _postprocessTimesMs.add(postprocessStopwatch.elapsedMilliseconds);

      print(
        '  Run ${i + 1}: ${stopwatch.elapsedMilliseconds}ms '
        '(Inference: ${stopwatch.elapsedMilliseconds - postprocessStopwatch.elapsedMilliseconds}ms, '
        'Post-process: ${postprocessStopwatch.elapsedMilliseconds}ms)',
      );

      // Nghỉ giữa các lần chạy
      if (i < runs - 1) {
        await Future.delayed(Duration(milliseconds: 200));
      }
    }

    // Tính toán thống kê
    final metrics = _calculateMetrics();
    _printReport(metrics);

    return metrics;
  }

  InferenceMetrics _calculateMetrics() {
    if (_inferenceTimesMs.isEmpty) {
      return InferenceMetrics.empty();
    }

    final totalRuns = _inferenceTimesMs.length;

    // Inference time
    final inferenceAvg = _inferenceTimesMs.reduce((a, b) => a + b) ~/ totalRuns;
    final inferenceMin = _inferenceTimesMs.reduce((a, b) => a < b ? a : b);
    final inferenceMax = _inferenceTimesMs.reduce((a, b) => a > b ? a : b);

    // Preprocess time
    final preprocessAvg =
        _preprocessTimesMs.isNotEmpty
            ? _preprocessTimesMs.reduce((a, b) => a + b) ~/
                _preprocessTimesMs.length
            : 0;

    // Postprocess time
    final postprocessAvg =
        _postprocessTimesMs.isNotEmpty
            ? _postprocessTimesMs.reduce((a, b) => a + b) ~/
                _postprocessTimesMs.length
            : 0;

    // Tính độ lệch chuẩn
    final variance =
        _inferenceTimesMs
            .map((time) => pow(time - inferenceAvg, 2))
            .reduce((a, b) => a + b) /
        totalRuns;
    final stdDev = sqrt(variance).round();

    return InferenceMetrics(
      totalRuns: totalRuns,
      inferenceAvgMs: inferenceAvg,
      inferenceMinMs: inferenceMin,
      inferenceMaxMs: inferenceMax,
      inferenceStdDevMs: stdDev,
      preprocessAvgMs: preprocessAvg,
      postprocessAvgMs: postprocessAvg,
      allTimesMs: List.from(_inferenceTimesMs),
      fps: 1000 / inferenceAvg,
    );
  }

  void _printReport(InferenceMetrics metrics) {
    print('''
📈 ========== INFERENCE PERFORMANCE REPORT ==========
🔄 Samples: ${metrics.totalRuns} runs
⏱️  Total Average: ${metrics.inferenceAvgMs}ms (${metrics.fps.toStringAsFixed(1)} FPS)
├── Preprocessing: ${metrics.preprocessAvgMs}ms
├── Core Inference: ${metrics.inferenceAvgMs - metrics.preprocessAvgMs - metrics.postprocessAvgMs}ms
└── Postprocessing: ${metrics.postprocessAvgMs}ms
📊 Range: ${metrics.inferenceMinMs}ms - ${metrics.inferenceMaxMs}ms (±${metrics.inferenceStdDevMs}ms)
📋 All times: ${metrics.allTimesMs.join(', ')}ms
===================================================
''');
  }
}
