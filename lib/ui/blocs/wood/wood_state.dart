import 'package:swin/constants/base_status.dart';
import 'package:swin/models/wood_piece.dart';

class WoodState {
  final BaseStatus status;
  final List<WoodPiece> woods;
  final String size;
  final int limit;
  final int offset;
  final bool canLoadMore;

  WoodState({
    this.status = BaseStatus.none,
    this.woods = const [],
    this.size = '',
    this.limit = 10,
    this.offset = 0,
  }) : canLoadMore = woods.length >= limit;

  WoodState copyWith({
    BaseStatus? status,
    List<WoodPiece>? woods,
    String? size,
    int? limit,
    int? offset,
  }) {
    return WoodState(
      status: status ?? this.status,
      woods: woods ?? this.woods,
      size: size ?? this.size,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
