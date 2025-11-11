import 'package:swin/constants/base_status.dart';
import 'package:swin/models/wood_database.dart';

class LibraryState {
  final BaseStatus status;
  final List<WoodDatabase> databases;
  final String? errorMessage;

  LibraryState({
    this.status = BaseStatus.none,
    this.databases = const [],
    this.errorMessage,
  });
}
