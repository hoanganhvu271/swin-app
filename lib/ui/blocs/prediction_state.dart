part of 'prediction_bloc.dart';

class PredictionState {
  final BaseStatus status;
  final List<AiModel> models;
  final  AiModel selectedModel;
  final File? input;
  final String? prediction;
  final bool predicted;
  final String? errorMessage;

   PredictionState({
    this.status = BaseStatus.none,
    this.models = const [],
    this.selectedModel = const AiModel(
      name: "Swin tiny",
      path: "assets/models/swinv2_tiny.onnx",
      dataset: "Bd11",
        description: "Trained on 224x224 images with 5 epochs, achieving approximately 85% accuracy.",
        classNames: [
          'Alantoma_decandra',
          'Caraipa_densifolia',
          'Cariniana_micrantha',
          'Caryocar_villosum',
          'Clarisia_racemosa',
          'Dipteryx_odorata',
          'Goupia_glabra',
          'Handroanthus_incanus',
          'Lueheopsis_duckeana',
          'Osteophloeum_platyspermum',
          'Pouteria_caimito',
        ]
    ),
    this.input,
    this.predicted = false,
    this.prediction,
    this.errorMessage,
  });

  PredictionState copyWith({
    BaseStatus? status,
    List<AiModel>? models,
    AiModel? selectedModel,
    File? input,
    String? prediction,
    String? errorMessage,
    bool? predicted,
  }) {
    return PredictionState(
      status: status ?? this.status,
      models: models ?? this.models,
      input: input ?? this.input,
      selectedModel: selectedModel ?? this.selectedModel,
      prediction: prediction ?? this.prediction,
      errorMessage: errorMessage ?? this.errorMessage,
      predicted: predicted ?? this.predicted,
    );
  }
}
