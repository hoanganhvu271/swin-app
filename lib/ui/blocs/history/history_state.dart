import 'package:swin/constants/base_status.dart';
import 'package:swin/models/prediction_result.dart';

class HistoryState {
  final BaseStatus status;
  final List<PredictionStorageObject> history;

  HistoryState({
    this.status = BaseStatus.none,
    this.history = const [],
  });

  HistoryState copyWith({
    BaseStatus? status,
    List<PredictionStorageObject>? history,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
    );
  }
}