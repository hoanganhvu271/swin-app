class AiModel {
  final String name;
  final String path;
  final String dataset;
  final String description;
  final bool isDownloaded;
  final List<String> classNames;

  const AiModel({
    required this.name,
    required this.path,
    required this.dataset,
    required this.description,
    this.isDownloaded = false,
    required this.classNames,
  });

  AiModel copyWith({
    String? name,
    String? path,
    String? dataset,
    String? description,
    bool? isDownloaded,
    List<String>? classNames,
  }) {
    return AiModel(
      name: name ?? this.name,
      path: path ?? this.path,
      dataset: dataset ?? this.dataset,
      description: description ?? this.description,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      classNames: classNames ?? this.classNames,
    );
  }
}
