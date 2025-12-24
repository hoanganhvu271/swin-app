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
      path: "assets/models/big_yolo.onnx",
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
    '1. Acer saccharinum',
    '2. Acacia melanoxylon',
    '3. Afzelia africana',
    '4. Afzelia pachyloba',
    '5. Afzelia quanzensis',
    '6. Albizia lucida',
    '7. Allophylus cobbe',
    '8. Anisoptera costata',
    '9. Apuleia leiocarpa',
    '10. Artocarpus calophyllus',
    '11. Artocarpus heterophyllus',
    '12. Autranella congolensis',
    '13. Berlinia bracteosa',
    '14. Betula pendula',
    '15. Bobgunnia fistuloides',
    '16. Brachystegia sp.',
    '17. Burckella obovata',
    '18. Burretiodendron tonkinense',
    '19. Calocedrus sp.',
    '20. Callitris columellaris',
    '21. Canarium album',
    '22. Chrysophyllum sp.',
    '23. Cinnamomum camphora',
    '24. Clarisia racemosa',
    '25. Colophospermum mopane',
    '26. Cunninghamia lanceolata',
    '27. Cupressus funebris',
    '28. Cylicodiscus gabunensis',
    '29. Dalbergia cochinchinensis',
    '30. Dalbergia oliveri',
    '31. Detarium macrocarpum',
    '32. Dialium bipindense',
    '33. Didelotia africana',
    '34. Diospyros mun',
    '35. Diospyros salletii',
    '36. Distemonanthus benthamianus',
    '37. Engelhardia chrysolepis',
    '38. Entandrophragma cylindricum',
    '39. Entandrophragma utile',
    '40. Erythrophleum fordii',
    '41. Erythrophleum ivorense',
    '42. Eucalyptus cladocalyx',
    '43. Eucalyptus grandis',
    '44. Eucalyptus microcorys',
    '45. Eucalyptus saligna',
    '46. Fokienia hodginsii',
    '47. Fraxinus excelsior',
    '48. Gilbertiodendron dewevrei',
    '49. Guarea cedrata',
    '50. Guibourtia coleosperma',
    '51. Hevea brasiliensis',
    '52. Heritiera littoralis',
    '53. Homalium caryophyllaceum',
    '54. Homalium foetidum',
    '55. Hopea iriana',
    '56. Hopea pierrei',
    '57. Hymenaea courbaril',
    '58. Hymenolobium heterocarpum',
    '59. Juglans regia',
    '60. Khaya senegalensis',
    '61. Klainedoxa gabonensis',
    '62. Lithocarpus ducampii',
    '63. Lophira alata',
    '64. Magnolia hypolampra',
    '65. Martiodendron parviflorum',
    '66. Milicia excelsa',
    '67. Milicia regia',
    '68. Millettia laurentii',
    '69. Monopetalanthus letestui',
    '70. Myracrodruon urundeuva',
    '71. Myroxylon balsamum',
    '72. Myroxylon peruiferum',
    '73. Nauclea diderrichii',
    '74. Pachyelasma tessmannii',
    '75. Palaquium waburgianum',
    '76. Pericopsis elata',
    '77. Pinus sp.',
    '78. Piptadeniastrum africanum',
    '79. Populus sp.',
    '80. Prunus serotina',
    '81. Pterocarpus macrocarpus',
    '82. Pterocarpus soyauxii',
    '83. Pterocarpus sp.',
    '84. Qualea paraensis',
    '85. Quercus petraea',
    '86. Quercus robur',
    '87. Quercus rubra',
    '88. Samanea saman',
    '89. Shorea hypochra',
    '90. Shorea roxburghii',
    '91. Sindora cochinchinensis',
    '92. Staudtia stipitata',
    '93. Syzygium hemisphericum',
    '94. Tarrietia cochinchinensis',
    '95. Tectona grandis',
    '96. Terminalia superba',
    '97. Tetraberlinia bifoliolata',
    '98. Toona sureni',
    '99. Xylia xylocarpa',
    '100. Zygia sp.',
  ];
}
