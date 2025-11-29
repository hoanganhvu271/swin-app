import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:swin/models/ai_model.dart';

class OnnxPredictor {
  late OrtSession _session;
  final OrtEnv _env = OrtEnv.instance;
  late AiModel model;

  Future<void> initModelFromBytes(Uint8List bytes) async {
    OrtSessionOptions options = OrtSessionOptions();
    _session = OrtSession.fromBuffer(bytes, options);
  }

  Future<List<double>> predict(Uint8List imageBytes) async {
    // Decode ảnh
    final image = img.decodeImage(imageBytes)!;
    final resized = img.copyResize(image, width: 224, height: 224);

    // Chuyển ảnh sang tensor (1, 3, 224, 224)
    final input = Float32List(1 * 3 * 224 * 224);
    int index = 0;

    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y); // img.Color

          double value;
          if (c == 0) {
            value = pixel.r / 255.0;
          } else if (c == 1) {
            value = pixel.g / 255.0;
          } else {
            value = pixel.b / 255.0;
          }

          // Chuẩn hóa theo ImageNet
          // input[index++] = (value - mean[c]) / std[c];
          input[index++] = value;
        }
      }
    }

    final inputTensor = OrtValueTensor.createTensorWithDataList(
      input,
      [1, 3, 224, 224],
    );


    final inputs = {'images': inputTensor};
    final runOptions = OrtRunOptions();
    final dynamic asyncResults = await _session.runAsync(runOptions, inputs);

    // Tìm OrtValue đầu tiên trong cấu trúc trả về
    OrtValue? firstOrt;
    if (asyncResults is List && asyncResults.isNotEmpty) {
      // asyncResults[0] có thể là List<OrtValue?> hoặc OrtValue
      final firstContainer = asyncResults[0];
      if (firstContainer is List && firstContainer.isNotEmpty) {
        firstOrt = firstContainer[0] as OrtValue?;
      } else if (firstContainer is OrtValue) {
        firstOrt = firstContainer as OrtValue?;
      }
    }

    if (firstOrt == null) throw Exception('No output from runAsync');
    final dynamic raw = firstOrt.value;

    // Chuẩn hoá về List<double>
    List<double> outputList;

    if (raw is Float32List) {
      outputList = raw.map((e) => e.toDouble()).toList();
    } else if (raw is List<double>) {
      outputList = List<double>.from(raw);
    } else if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is List) {
        // Trường hợp 2D: [[...]]
        outputList = first.map((e) => (e as num).toDouble()).toList();
      } else if (first is num) {
        // Trường hợp 1D: [...]
        outputList = raw.map((e) => (e as num).toDouble()).toList();
      } else {
        throw Exception('Unsupported nested type: ${first.runtimeType}');
      }
    } else {
      throw Exception('Unsupported output data type: ${raw.runtimeType}');
    }

    // return outputList.indexWhere((e) => e == outputList.reduce((a, b) => a > b ? a : b));
    print("vuha12: $outputList");
    return outputList;
  }

  void close() {
    try {
      _session.release();
    } catch (_) {}
    _env.release();
  }
}
