import 'package:swin/models/wood_piece.dart';

class WoodDatabase {
  final String id;
  final String cover;
  final String title;
  final String description;
  final int size;

  WoodDatabase({
    required this.id,
    this.cover = '',
    this.title = '',
    this.description = '',
    this.size = 0
  });
}
