import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/locators/swin_locators.dart';
import 'dart:typed_data';

import 'package:swin/models/ai_model.dart';
import 'package:swin/onnx_predictor.dart';
import 'package:swin/repository/model_repository.dart';

import '../../constants/base_status.dart';

part 'prediction_event.dart';
part 'prediction_state.dart';

Future<int> _isolatedPredictionTask(Map<String, dynamic> data) async {
  final File input = data['input'] as File;
  final Uint8List modelBytes = data['modelBytes'] as Uint8List;
  final List<String> classNames = List<String>.from(data['classNames'] as List);

  final OnnxPredictor isolatedPredictor = OnnxPredictor();

  try {
    // Khởi tạo model trong isolate — nặng, nhưng không ảnh hưởng UI
    await isolatedPredictor.initModelFromBytes(modelBytes);

    final isolatedBytes = await input.readAsBytes();
    final result = await isolatedPredictor.predict(isolatedBytes);
    return result;
  } finally {
    isolatedPredictor.close();
  }
}


class PredictionBloc extends Bloc<PredictionEvent, PredictionState>{
  // Bỏ đi late final OnnxPredictor _predictor; vì nó sẽ được khởi tạo trong Isolate
  // Nếu bạn vẫn cần _predictor cho các tác vụ khác, hãy giữ lại nó,
  // nhưng nó KHÔNG được dùng trong _onPredictionRequested.
  late final OnnxPredictor _predictor = OnnxPredictor(); // Giữ lại cho initRuntimeRequested

  PredictionBloc() : super(PredictionState()) {
    on<PredictionRequested>(_onPredictionRequested);
    on<PredictionReset>(_onPredictionReset);
    on<PredictionInputChanged>((event, emit) {
      emit(state.copyWith(input: event.input));
    });
    on<PredictionModelLoaded>(_onPredictionModelLoaded);
    on<InitRuntimeRequested>(_initRuntimeRequested);
    on<PredictionModelListFetched>(_predictionModelListFetched);

    add(InitRuntimeRequested());
  }

  void _predictionModelListFetched(PredictionModelListFetched event, Emitter<PredictionState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      final models = swinLocator<ModelRepository>().getModelList();
      emit(state.copyWith(status: BaseStatus.success, models: models));
    } catch (e) {
      emit(state.copyWith(status: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  void _initRuntimeRequested(InitRuntimeRequested event, emit) async {
    emit(state.copyWith(status: BaseStatus.loading));

    // Giả sử OnnxPredictor() chỉ khởi tạo OrtEnv, tác vụ này nhanh
    // Nếu nó nặng, bạn cũng nên chuyển nó sang compute
    // _predictor = OnnxPredictor(); // đã được khai báo ở trên
    emit(state.copyWith(status: BaseStatus.success));
  }

  void _onPredictionRequested(PredictionRequested event, Emitter<PredictionState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      // Load model bytes trong main isolate (nhanh)
      final rawBytes = await rootBundle.load(state.selectedModel.path);
      final modelBytes = rawBytes.buffer.asUint8List();

      final Map<String, dynamic> data = {
        'input': state.input!,
        'modelBytes': modelBytes,
        'classNames': state.selectedModel.classNames,
      };

      // Chạy trong isolate — init + predict
      final result = await compute<Map<String, dynamic>, int>(
        _isolatedPredictionTask,
        data,
      );

      final className = state.selectedModel.classNames[result];
      emit(state.copyWith(
        status: BaseStatus.success,
        prediction: className,
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