part of 'prediction_bloc.dart';

class PredictionState {
  final BaseStatus status;
  final List<AiModel> models;
  final  AiModel? selectedModel;
  final File? input;
  final List<PredictionResult> predictions;
  final bool predicted;
  final String? errorMessage;

   PredictionState({
    this.status = BaseStatus.none,
    this.models = const [],
    this.selectedModel,
    this.input,
    this.predicted = false,
    this.predictions = const [],
    this.errorMessage,
  });

  PredictionState copyWith({
    BaseStatus? status,
    List<AiModel>? models,
    AiModel? selectedModel,
    File? input,
    List<PredictionResult>? predictions,
    String? errorMessage,
    bool? predicted,
  }) {
    return PredictionState(
      status: status ?? this.status,
      models: models ?? this.models,
      input: input ?? this.input,
      selectedModel: selectedModel ?? this.selectedModel,
      predictions: predictions ?? this.predictions,
      errorMessage: errorMessage ?? this.errorMessage,
      predicted: predicted ?? this.predicted,
    );
  }
}
