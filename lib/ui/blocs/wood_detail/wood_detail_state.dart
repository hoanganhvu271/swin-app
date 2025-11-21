import 'package:swin/constants/base_status.dart';

import '../../../models/wood_piece.dart';

class WoodDetailState {
  final BaseStatus status;
  final WoodPiece? woodPiece;
  final String? error;

  WoodDetailState({
    this.status = BaseStatus.none,
    this.woodPiece,
    this.error,
  });

  WoodDetailState copyWith({
    BaseStatus? status,
    WoodPiece? woodPiece,
    String? error,
  }) {
    return WoodDetailState(
      status: status ?? this.status,
      woodPiece: woodPiece ?? this.woodPiece,
      error: error ?? this.error,
    );
  }
}