import 'class_info.dart';

class AiModel {
  final String name;
  final String path;
  final String dataset;
  final String description;
  final bool isDownloaded;
  final List<ClassInfo> classInfos;


  const AiModel({
    required this.name,
    required this.path,
    required this.dataset,
    required this.description,
    this.isDownloaded = false,
    required this.classInfos,
  });

  AiModel copyWith({
    String? name,
    String? path,
    String? dataset,
    String? description,
    bool? isDownloaded,
    List<ClassInfo>? classInfos,
  }) {
    return AiModel(
      name: name ?? this.name,
      path: path ?? this.path,
      dataset: dataset ?? this.dataset,
      description: description ?? this.description,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      classInfos: classInfos ?? this.classInfos,
    );
  }
}
