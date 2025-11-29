import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:swin/core/http/result.dart';
import 'package:swin/locators/swin_locators.dart';
import 'package:swin/models/ai_model.dart';
import 'package:swin/models/model_metadata.dart';
import '../core/http/dio_client.dart';

class ModelService {
  Future<Result<ModelMetadata>> getLatestModel() async {
    try {
      Response json = await swinLocator<DioClient>().get("/model-api/version");

      return Result.success(data: ModelMetadata.fromJson(json.data));
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? "Lỗi không xác định";
      return Result.failure(
        message: errorMessage,
        code: e.response?.statusCode ?? -1,
      );
    } catch (e) {
      return Result.failure(message: e.toString());
    }
  }
}