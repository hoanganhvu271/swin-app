class ModelMetadata {
  final String name;
  final int version;
  final int size;
  final String checksum;
  final String downloadUrl;

  ModelMetadata({
    required this.name,
    required this.version,
    required this.size,
    required this.checksum,
    required this.downloadUrl,
  });

  factory ModelMetadata.fromJson(Map<String, dynamic> json) {
    return ModelMetadata(
      name: json['name'] ?? '',
      version: json['version'] ?? 0,
      size: json['size'] ?? 0,
      checksum: json['checksum'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}
