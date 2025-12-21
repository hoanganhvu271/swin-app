import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prediction_result.dart';
import 'package:path/path.dart' as p;

class StorageUtils {
  static const String _key = 'prediction_history';
  static const int _maxItems = 5;

  static Future<void> addPrediction(PredictionStorageObject obj) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> historyJson = prefs.getStringList(_key) ?? [];

    final isFromCamera = obj.imgPath.contains("uvc_capture_tmp.jpg");
    String newFilePath = obj.imgPath;

    if (isFromCamera) {
      final directory = await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = '$timestamp.jpg';
      newFilePath = p.join(directory.path, newFileName);

      try {
        final originalFile = File(obj.imgPath);
        if (await originalFile.exists()) {
          await originalFile.copy(newFilePath);
        }
      } catch (e) {
        print('Lỗi copy file: $e');
      }
    }

    Map<String, dynamic> objMap = {
      'imgPath': newFilePath,
      'result': obj.result.map((r) => {
        'label': r.label,
        'index': r.index,
        'confidence': r.confidence,
      }).toList(),
      'timestamp': obj.timestamp,
    };

    historyJson.add(jsonEncode(objMap));

    if (historyJson.length > _maxItems) {
      historyJson = historyJson.sublist(historyJson.length - _maxItems);
    }

    await prefs.setStringList(_key, historyJson);
  }

  static Future<List<PredictionStorageObject>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_key) ?? [];

    return historyJson.map((str) {
      final map = jsonDecode(str);
      return PredictionStorageObject(
        imgPath: map['imgPath'],
        result: (map['result'] as List).map((r) => PredictionResult(
          label: r['label'],
          index: r['index'],
          confidence: (r['confidence'] as num).toDouble(),
        )).toList(),
        timestamp: map['timestamp'] ?? '',
      );
    }).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> removePredictionByTimestamp(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyJson = prefs.getStringList(_key) ?? [];

    historyJson.removeWhere((str) {
      final map = jsonDecode(str);
      return map['timestamp'] == timestamp;
    });

    await prefs.setStringList(_key, historyJson);
  }
}
