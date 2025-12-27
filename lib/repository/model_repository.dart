import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:swin/core/http/result.dart';
import 'package:swin/models/ai_model.dart';

import '../models/class_info.dart';
import 'model_service.dart';

class ModelRepository {
  final ModelService _service = ModelService();

  static const String _localVersionKey = "local_model_version";
  static const String _localModelFileKey = "local_model_path";
  static const String _needUpdatedKey = "local_model_need_update";

  Future<AiModel> getCurrentModel() async {
    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString(_localModelFileKey);
    final List<ClassInfo> classInfos = classObjects.map((e) => ClassInfo(
      id: e['id'] ?? 'vn100',
      name: e['name'] ?? 'Unknown',
    )).toList();

    if (localPath != null && File(localPath).existsSync()) {
      return AiModel(
        name: "YOLOv11",
        path: localPath,
        dataset: "VN_26",
        isDownloaded: true,
        description: "Model downloaded",
        classInfos: classInfos
      );
    }

    return AiModel(
      name: "YOLOv11",
      path: "assets/models/big_yolo.onnx",
      dataset: "VN_26",
      isDownloaded: false,
      description: "Default bundled model",
      classInfos: classInfos
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

  final List<Map<String, String>> classObjects = [
    {"id": "vn100", "name": "Acer saccharinum"},
    {"id": "vn100", "name": "Acacia melanoxylon"},
    {"id": "vn26_01", "name": "Afzelia africana"},
    {"id": "vn_26_02", "name": "Afzelia pachyloba"},
    {"id": "vn100", "name": "Afzelia quanzensis"},
    {"id": "vn100", "name": "Albizia lucida"},
    {"id": "vn100", "name": "Allophylus cobbe"},
    {"id": "vn100", "name": "Anisoptera costata"},
    {"id": "vn100", "name": "Apuleia leiocarpa"},
    {"id": "vn100", "name": "Artocarpus calophyllus"},
    {"id": "vn100", "name": "Artocarpus heterophyllus"},
    {"id": "vn_26_03", "name": "Autranella congolensis"},
    {"id": "vn_26_04", "name": "Berlinia bracteosa"},
    {"id": "vn100", "name": "Betula pendula"},
    {"id": "vn100", "name": "Bobgunnia fistuloides"},
    {"id": "vn100", "name": "Brachystegia sp."},
    {"id": "vn100", "name": "Burckella obovata"},
    {"id": "vn100", "name": "Burretiodendron tonkinense"},
    {"id": "vn100", "name": "Calocedrus sp."},
    {"id": "vn100", "name": "Callitris columellaris"},
    {"id": "vn100", "name": "Canarium album"},
    {"id": "vn100", "name": "Chrysophyllum sp."},
    {"id": "vn100", "name": "Cinnamomum camphora"},
    {"id": "vn100", "name": "Clarisia racemosa"},
    {"id": "vn100", "name": "Colophospermum mopane"},
    {"id": "vn100", "name": "Cunninghamia lanceolata"},
    {"id": "vn100", "name": "Cupressus funebris"},
    {"id": "vn_26_06", "name": "Cylicodiscus gabunensis"},
    {"id": "vn100", "name": "Dalbergia cochinchinensis"},
    {"id": "vn100", "name": "Dalbergia oliveri"},
    {"id": "vn_26_09", "name": "Detarium macrocarpum"},
    {"id": "vn100", "name": "Dialium bipindense"},
    {"id": "vn100", "name": "Didelotia africana"},
    {"id": "vn100", "name": "Diospyros mun"},
    {"id": "vn100", "name": "Diospyros salletii"},
    {"id": "vn_26_10", "name": "Distemonanthus benthamianus"},
    {"id": "vn100", "name": "Engelhardia chrysolepis"},
    {"id": "vn_26_11", "name": "Entandrophragma cylindricum"},
    {"id": "vn100", "name": "Entandrophragma utile"},
    {"id": "vn100", "name": "Erythrophleum fordii"},
    {"id": "vn100", "name": "Erythrophleum ivorense"},
    {"id": "vn100", "name": "Eucalyptus cladocalyx"},
    {"id": "vn100", "name": "Eucalyptus grandis"},
    {"id": "vn100", "name": "Eucalyptus microcorys"},
    {"id": "vn100", "name": "Eucalyptus saligna"},
    {"id": "vn100", "name": "Fokienia hodginsii"},
    {"id": "vn100", "name": "Fraxinus excelsior"},
    {"id": "vn100", "name": "Gilbertiodendron dewevrei"},
    {"id": "vn_26_13", "name": "Guarea cedrata"},
    {"id": "vn_26_14", "name": "Guibourtia coleosperma"},
    {"id": "vn100", "name": "Hevea brasiliensis"},
    {"id": "vn100", "name": "Heritiera littoralis"},
    {"id": "vn100", "name": "Homalium caryophyllaceum"},
    {"id": "vn100", "name": "Homalium foetidum"},
    {"id": "vn100", "name": "Hopea iriana"},
    {"id": "vn100", "name": "Hopea pierrei"},
    {"id": "vn100", "name": "Hymenaea courbaril"},
    {"id": "vn100", "name": "Hymenolobium heterocarpum"},
    {"id": "vn100", "name": "Juglans regia"},
    {"id": "vn100", "name": "Khaya senegalensis"},
    {"id": "vn100", "name": "Klainedoxa gabonensis"},
    {"id": "vn100", "name": "Lithocarpus ducampii"},
    {"id": "vn100", "name": "Lophira alata"},
    {"id": "vn100", "name": "Magnolia hypolampra"},
    {"id": "vn100", "name": "Martiodendron parviflorum"},
    {"id": "vn_26_17", "name": "Milicia excelsa"},
    {"id": "vn100", "name": "Milicia regia"},
    {"id": "vn_26_18", "name": "Millettia laurentii"},
    {"id": "vn100", "name": "Monopetalanthus letestui"},
    {"id": "vn100", "name": "Myracrodruon urundeuva"},
    {"id": "vn100", "name": "Myroxylon balsamum"},
    {"id": "vn100", "name": "Myroxylon peruiferum"},
    {"id": "vn_26_20", "name": "Nauclea diderrichii"},
    {"id": "vn_26_21", "name": "Pachyelasma tessmannii"},
    {"id": "vn100", "name": "Palaquium waburgianum"},
    {"id": "vn100", "name": "Pericopsis elata"},
    {"id": "vn100", "name": "Pinus sp."},
    {"id": "vn_26_22", "name": "Piptadeniastrum africanum"},
    {"id": "vn100", "name": "Populus sp."},
    {"id": "vn100", "name": "Prunus serotina"},
    {"id": "vn100", "name": "Pterocarpus macrocarpus"},
    {"id": "vn_26_25", "name": "Pterocarpus soyauxii"},
    {"id": "vn_26_23", "name": "Pterocarpus sp."},
    {"id": "vn100", "name": "Qualea paraensis"},
    {"id": "vn100", "name": "Quercus petraea"},
    {"id": "vn100", "name": "Quercus robur"},
    {"id": "vn100", "name": "Quercus rubra"},
    {"id": "vn100", "name": "Samanea saman"},
    {"id": "vn100", "name": "Shorea hypochra"},
    {"id": "vn100", "name": "Shorea roxburghii"},
    {"id": "vn100", "name": "Sindora cochinchinensis"},
    {"id": "vn100", "name": "Staudtia stipitata"},
    {"id": "vn100", "name": "Syzygium hemisphericum"},
    {"id": "vn100", "name": "Tarrietia cochinchinensis"},
    {"id": "vn100", "name": "Tectona grandis"},
    {"id": "vn100", "name": "Terminalia superba"},
    {"id": "vn100", "name": "Tetraberlinia bifoliolata"},
    {"id": "vn100", "name": "Toona sureni"},
    {"id": "vn100", "name": "Xylia xylocarpa"},
    {"id": "vn100", "name": "Zygia sp."},
  ];
}
