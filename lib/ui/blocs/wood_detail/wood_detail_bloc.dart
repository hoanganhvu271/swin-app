import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/ui/blocs/wood_detail/wood_detail_event.dart';
import 'package:swin/ui/blocs/wood_detail/wood_detail_state.dart';

import '../../../constants/base_status.dart';
import '../../../locators/swin_locators.dart';
import '../../../repository/wood_repository.dart';

class WoodDetailBloc extends Bloc<WoodDetailEvent, WoodDetailState> {
  late final repo = swinLocator<WoodRepository>();

  WoodDetailBloc() : super(WoodDetailState()) {
    on<GetWoodById>(_onGetWoodById);
  }

  Future<void> _onGetWoodById(GetWoodById event, emit) async {
    emit(state.copyWith(status: BaseStatus.loading));

    try {
      int index = event.woodId + 1;
      String id = "vn_26_${index.toString().padLeft(2, '0')}";
      final result = await repo.getWoodById(id);

      if (result != null) {
        emit(state.copyWith(
          status: BaseStatus.success,
          woodPiece: result,
        ));
      } else {
        emit(state.copyWith(
          status: BaseStatus.failure,
          error: 'Not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BaseStatus.failure,
        error: e.toString(),
      ));
    }
  }
}