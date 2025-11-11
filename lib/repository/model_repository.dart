import 'package:swin/models/ai_model.dart';

class ModelRepository {
  List<AiModel> getModelList() {
    AiModel model = AiModel(
        name: "SwinV2 Tiny",
        path: "assets/models/swinv2_tiny.onnx",
        dataset: "BD_11",
        isDownloaded: true,
        description: "BD_11 is a 2021 dataset containing 440 images of 11 commercial wood species from the Amazon rainforest. All images were captured at 50× magnification. The wood samples were not polished, only cut with a pocket knife to expose the anatomical structure. Each species includes 40 images (from 10 specimens × 4 images each), collected using a low-cost handheld microscope connected to a smartphone with a 640×480 px resolution.",
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

    return [
      model,
      AiModel(
          name: "SwinV2 Tiny",
          path: "assets/models/swinv2_tiny.onnx",
          dataset: "BFS_46",
          isDownloaded: true,
          description: "BD_11 is a 2021 dataset containing 440 images of 11 commercial wood species from the Amazon rainforest. All images were captured at 50× magnification. The wood samples were not polished, only cut with a pocket knife to expose the anatomical structure. Each species includes 40 images (from 10 specimens × 4 images each), collected using a low-cost handheld microscope connected to a smartphone with a 640×480 px resolution.",
          classNames: []
      ),
      AiModel(
          name: "SwinV2 Tiny",
          path: "assets/models/swinv2_tiny.onnx",
          dataset: "PCA_11",
          description: "...",
          classNames: []
      ),
      AiModel(
          name: "SwinV2 Tiny",
          path: "assets/models/swinv2_tiny.onnx",
          dataset: "VN26_10x",
          description: "...",
          classNames: []
      ),
      AiModel(
          name: "SwinV2 Tiny",
          path: "assets/models/swinv2_tiny.onnx",
          dataset: "VN26_20x",
          description: "...",
          classNames: []
      ),
      AiModel(
          name: "SwinV2 Tiny",
          path: "assets/models/swinv2_tiny.onnx",
          dataset: "VN26_50x",
          description: "...",
          classNames: []
      ),
      AiModel(
          name: "SwinV2 Tiny",
          path: "assets/models/swinv2_tiny.onnx",
          dataset: "WRD_21",
          description: "...",
          classNames: []
      )
    ];
  }
}