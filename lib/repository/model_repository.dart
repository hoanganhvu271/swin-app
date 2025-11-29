import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:swin/core/http/result.dart';
import 'package:swin/models/ai_model.dart';

import 'model_service.dart';

class ModelRepository {
  final ModelService _service = ModelService();

  static const String _localVersionKey = "local_model_version";
  static const String _localModelFileKey = "local_model_path";
  static const String _needUpdatedKey = "local_model_need_update";

  Future<AiModel> getCurrentModel() async {
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString(_localModelFileKey);

    if (localPath != null && File(localPath).existsSync()) {
      return AiModel(
        name: "YOLOv11",
        path: localPath,
        dataset: "VN_26",
        isDownloaded: true,
        description: "Model downloaded",
        classNames: _classNames,
      );
    }

    return AiModel(
      name: "YOLOv11",
      path: "assets/models/best.onnx",
      dataset: "VN_26",
      isDownloaded: false,
      description: "Default bundled model",
      classNames: _classNames,
    );
  }

  Future<bool> checkLatestVersion() async {
    final prefs = await SharedPreferences.getInstance();

    final bool needUpdate = prefs.getBool(_needUpdatedKey) ?? false;
    if (needUpdate) return true;

    final localVersion = prefs.getString(_localVersionKey) ?? "0";

    final result = await _service.getLatestModel();

    print("Checking latest version...: ${result.isSuccessful}");
    if (!result.isSuccessful) return false;

    final serverVersion = result.unwrap().version.toString();
    print("Local version: $localVersion, Server version: $serverVersion");
    return serverVersion != localVersion;
  }

  Future<Result> updateModel() async {
    final modelInfoResult = await _service.getLatestModel();
    if (!modelInfoResult.isSuccessful) {
      return Result.failure(message: "Không lấy được version từ server");
    }

    final modelInfo = modelInfoResult.unwrap();

    http.Response downloadResponse;
    try {
      downloadResponse = await http.get(Uri.parse(modelInfo.downloadUrl));
      if (downloadResponse.statusCode != 200) {
        return Result.failure(message: "Tải model thất bại: HTTP ${downloadResponse.statusCode}");
      }
    } catch (e) {
      return Result.failure(message: "Lỗi tải model: $e");
    }

    Uint8List bytes = downloadResponse.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory(p.join(dir.path, "models"));

    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    final filePath = p.join(modelDir.path, "latest_model.onnx");
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localVersionKey, modelInfo.version.toString());
    await prefs.setString(_localModelFileKey, filePath);
    await prefs.setBool(_needUpdatedKey, false);

    return Result.success();
  }

  Future<void> markNeedUpdate(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_needUpdatedKey, value);
  }

  final List<String> _classNames = const [
    'Afzelia africana Smith (Gỗ Afzelia châu Phi)',
    'Afzelia pachyloba Harms (Gỗ Afzelia to)',
    'Autranella congolensis A.Chev (Gỗ Autranella)',
    'Berlinia bracteosa Benth (Gỗ Berlinia)',
    'Brachystegia laurentii (DeWild.) Hoyle (Gỗ Brachystegia)',
    'Cylicodiscus gabunensis Harms (Gỗ Cylicodiscus)',
    'Dalbergia melanoxylon Guill.et Perr (Gỗ Mun đen)',
    'Daniellia thurifera Benn (Gỗ Daniellia)',
    'Detarium macrocarpum Harms (Gỗ Detarium)',
    'Distemonanthus benthamianus Baill (Gỗ Distemonanthus)',
    'Entandrophragma cylindricum Sprague (Gỗ Sapele)',
    'Erythrophleum suaveolens Brenan (Gỗ Erythrophleum)',
    'Guarea cedrata Pellegr (Gỗ Guarea)',
    'Guibourtia coleosperma (Benth.) Leonard (Gỗ Guibourtia)',
    'Guibourtia demeusei J.Leon (Gỗ Guibourtia Demeusei)',
    'Julbernardia pellegriniana Troupin (Gỗ Julbernardia)',
    'Milicia excelsa (Welw.) C.C.Berg (Gỗ Iroko)',
    'Millettia laurentii De Wild (Gỗ Wenge)',
    'Monopetalanthus coriaceus Mor (Gỗ Monopetalanthus)',
    'Nauclea diderrichii Merr (Gỗ Nauclea)',
    'Pachyelasma tessmannii (Harms) Harms (Gỗ Pachyelasma)',
    'Piptadeniastrum africanum Brenan (Gỗ Piptadeniastrum)',
    'Pterocarpus Jacq (Gỗ Pterocarpus)',
    'Pterocarpus angolensis DC (Gỗ Pterocarpus Angola)',
    'Pterocarpus soyauxii Taub (Gỗ Pterocarpus Soyauxii)',
    'Tieghemella africana Pierre (Gỗ Tieghemella)',
  ];
}
