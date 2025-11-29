import 'package:swin/constants/base_status.dart';

class UpdateState {
  final BaseStatus status;
  final String? errorMessage;
  final bool needUpdate;

  UpdateState({
    this.status = BaseStatus.none,
    this.errorMessage,
    this.needUpdate = false,
  });

  UpdateState copyWith({
    BaseStatus? status,
    String? errorMessage,
    bool? needUpdate,
  }) {
    return UpdateState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      needUpdate: needUpdate ?? this.needUpdate,
    );
  }
}