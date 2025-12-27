import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swin/locators/swin_locators.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

import 'package:swin/models/ai_model.dart';
import 'package:swin/onnx_predictor.dart';
import 'package:swin/repository/model_repository.dart';
import 'package:swin/utils/storage_utils.dart';

import '../../../constants/base_status.dart';
import '../../../models/prediction_result.dart';

part 'prediction_event.dart';
part 'prediction_state.dart';

Future<List<double>> _isolatedPredictionTask(Map<String, dynamic> data) async {
  final File input = data['input'] as File;
  final Uint8List modelBytes = data['modelBytes'] as Uint8List;

  final OnnxPredictor isolatedPredictor = OnnxPredictor();

  try {
    await isolatedPredictor.initModelFromBytes(modelBytes);

    final isolatedBytes = await input.readAsBytes();
    final result = await isolatedPredictor.predict(isolatedBytes);
    return result;
  } finally {
    isolatedPredictor.close();
  }
}

class PredictionBloc extends Bloc<PredictionEvent, PredictionState>{
  late final OnnxPredictor _predictor = OnnxPredictor();
  late final ModelRepository _modelRepository = swinLocator<ModelRepository>();

  PredictionBloc() : super(PredictionState()) {
    on<PredictionRequested>(_onPredictionRequested);
    on<PredictionReset>(_onPredictionReset);
    on<PredictionInputChanged>((event, emit) {
      print("PredictionInputChanged event received with input: ${event.input.path}");
      emit(state.copyWith(input: event.input));
    });
    on<PredictionModelLoaded>(_onPredictionModelLoaded);
    on<InitRuntimeRequested>(_initRuntimeRequested);
    on<PredictionModelListFetched>(_predictionModelListFetched);

    add(InitRuntimeRequested());
  }

  void _predictionModelListFetched(PredictionModelListFetched event, Emitter<PredictionState> emit) async {
    // emit(state.copyWith(status: BaseStatus.loading));
    // try {
    //   final models = swinLocator<ModelRepository>().getModelList();
    //   emit(state.copyWith(status: BaseStatus.success, models: models));
    // } catch (e) {
    //   emit(state.copyWith(status: BaseStatus.failure, errorMessage: e.toString()));
    // }
  }

  void _initRuntimeRequested(InitRuntimeRequested event, emit) async {
    emit(state.copyWith(status: BaseStatus.loading));

    AiModel currentModel = await _modelRepository.getCurrentModel();
    emit(state.copyWith(status: BaseStatus.success, selectedModel: currentModel));
  }

  Future<Uint8List> _loadModelBytes(String? localFileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final localPath = p.join(dir.path, localFileName ?? 'big_yolo.onnx');

    final file = File(localPath);
    if (await file.exists()) {
      print("vuha12: Loading model from local path: $localPath");
      return await file.readAsBytes();
    } else {
      print("vuha12: Loading model from assets");
      final rawBytes = await rootBundle.load('assets/models/big_yolo.onnx');
      final modelBytes = rawBytes.buffer.asUint8List();

      return modelBytes;
    }
  }

  void _onPredictionRequested(PredictionRequested event, Emitter<PredictionState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      final modelBytes = await _loadModelBytes(state.selectedModel?.path);

      final Map<String, dynamic> data = {
        'input': state.input!,
        'modelBytes': modelBytes
      };

      // Chạy trong isolate — init + predict
      final result = await compute<Map<String, dynamic>, List<double>>(
        _isolatedPredictionTask,
        data,
      );

      // Xử lý kết quả
      List<PredictionResult> predictions = <PredictionResult>[];

      for (int i = 0; i < result.length; i++) {
        predictions.add(PredictionResult(
          label: state.selectedModel?.classInfos[i].name ?? "Unknown",
          id: state.selectedModel?.classInfos[i].id ?? "vn100",
          confidence: result[i],
        ));
      }

      // Sắp xếp theo confidence giảm dần
      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      // History
      await StorageUtils.addPrediction(
        PredictionStorageObject(
          imgPath: state.input!.path,
          result: predictions,
          timestamp: DateTime.now().toIso8601String(),
        )
      );

      emit(state.copyWith(
        status: BaseStatus.success,
        predictions: predictions,
        predicted: true,
      ));
    } catch (e, st) {
      print("Error during prediction: $e\n$st");
      emit(state.copyWith(status: BaseStatus.failure, errorMessage: e.toString()));
    }
  }


  void _onPredictionModelLoaded(PredictionModelLoaded event, Emitter<PredictionState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      emit(state.copyWith(status: BaseStatus.success, selectedModel: event.model));
    } catch (e) {
      emit(state.copyWith(status: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onPredictionReset(PredictionReset event, Emitter<PredictionState> emit) {
    _predictor.close();
    emit(PredictionState());
  }
}