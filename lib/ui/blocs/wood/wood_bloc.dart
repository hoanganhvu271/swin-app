import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/locators/swin_locators.dart';
import 'package:swin/ui/blocs/wood/wood_event.dart';
import 'package:swin/ui/blocs/wood/wood_state.dart';

import '../../../constants/base_status.dart';
import '../../../repository/wood_repository.dart';

class WoodBloc extends Bloc<WoodEvent, WoodState>{
  late final repo = swinLocator<WoodRepository>();

  WoodBloc() : super(WoodState()) {
    on<GetWoodListEvent>(_onGetWoodListEvent);
  }

  Future<void> _onGetWoodListEvent(GetWoodListEvent event, emit) async {
    emit(state.copyWith(status: BaseStatus.loading));

    try {
      final result = await repo.getWoodsList(
        event.databaseId,
        state.offset,
        state.limit,
      );

      emit(state.copyWith(
        status: BaseStatus.success,
        woods: result,
        offset: state.offset + state.limit,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BaseStatus.failure
      ));
    }
  }
}

