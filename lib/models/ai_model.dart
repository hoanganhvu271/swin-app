class AiModel {
  final String name;
  final String path;
  final String dataset;
  final String description;
  final List<String> classNames;

  const AiModel({
    required this.name,
    required this.path,
    required this.dataset,
    required this.description,
    required this.classNames,
  });

  AiModel copyWith({
    String? name,
    String? path,
    String? dataset,
    String? description,
    List<String>? classNames,
  }) {
    return AiModel(
      name: name ?? this.name,
      path: path ?? this.path,
      dataset: dataset ?? this.dataset,
      description: description ?? this.description,
      classNames: classNames ?? this.classNames,
    );
  }
}
