class WoodDatabase {
  final String id;
  final String cover;
  final String title;
  final String description;
  final int size;
  final String image;

  WoodDatabase({
    required this.id,
    this.cover = '',
    this.title = '',
    this.description = '',
    this.size = 0,
    this.image = ''
  });
}
