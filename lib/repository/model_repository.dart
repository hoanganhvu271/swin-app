import 'package:swin/models/ai_model.dart';

class ModelRepository {
  List<AiModel> getModelList() {
    AiModel model = AiModel(
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
    );

    return List.generate(10, (index) {
      return model.copyWith(name: "${model.name} v${index + 1}");
    });
  }
}