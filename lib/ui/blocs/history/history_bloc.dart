import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/constants/base_status.dart';

import '../../../utils/storage_utils.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState()) {
    on<LoadHistory>(_onLoadHistory);
    on<ClearHistory>(_onClearHistory);
    on<RemoveHistoryItem>(_onRemoveHistoryItem);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      final history = await StorageUtils.getHistory();
      emit(state.copyWith(status: BaseStatus.success, history: history));
    } catch (e) {
      print(e);
      emit(state.copyWith(status: BaseStatus.failure));
    }
  }

  Future<void> _onClearHistory(ClearHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      await StorageUtils.clearHistory();
      emit(state.copyWith(status: BaseStatus.success, history: []));
    } catch (e) {
      emit(state.copyWith(status: BaseStatus.failure));
    }
  }

  Future<void> _onRemoveHistoryItem(RemoveHistoryItem event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));
    try {
      await StorageUtils.removePredictionByTimestamp(event.timestamp);
      final updatedHistory = state.history.where((item) => item.timestamp != event.timestamp).toList();
      emit(state.copyWith(status: BaseStatus.success, history: updatedHistory));
    } catch (e) {
      emit(state.copyWith(status: BaseStatus.failure));
    }
  }
}
