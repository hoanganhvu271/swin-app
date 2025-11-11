class WoodPiece {
  final String id;
  final List<String> images;
  final String name;
  final String description;
  final List<String> properties;
  final String origin;
  final List<String> relatedSpecies;

  WoodPiece({
    required this.id,
    required this.images,
    required this.name,
    required this.description,
    required this.origin,
    required this.properties,
    required this.relatedSpecies
  });
}
