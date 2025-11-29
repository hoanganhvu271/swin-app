import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/constants/base_status.dart';
import 'package:swin/repository/model_repository.dart';
import '../../../locators/swin_locators.dart';
import 'update_event.dart';
import 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  late final ModelRepository repository;

  UpdateBloc() : super(UpdateState()) {
    repository = swinLocator<ModelRepository>();

    on<CheckVersionEvent>(_onCheckVersion);
    on<DownloadModelEvent>(_onDownloadModel);
  }

  Future<void> _onCheckVersion(CheckVersionEvent event, Emitter<UpdateState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));

    try {
      final needUpdate = await repository.checkLatestVersion();

      emit(state.copyWith(
        status: BaseStatus.success,
        needUpdate: needUpdate
      ));
    } catch (e) {
      emit(state.copyWith(status: BaseStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onDownloadModel(DownloadModelEvent event, Emitter<UpdateState> emit) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final result = await repository.updateModel();
     result.when(
       onSuccess: (data) => emit(state.copyWith(status: BaseStatus.success, needUpdate: false)),
       onFailure: (code, message, error) => emit(state.copyWith(status: BaseStatus.failure, errorMessage: message, needUpdate: false))
     );
  }
}
