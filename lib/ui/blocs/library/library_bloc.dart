import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/locators/swin_locators.dart';
import 'package:swin/ui/blocs/library/library_event.dart';
import 'package:swin/ui/blocs/library/library_state.dart';

import '../../../constants/base_status.dart';
import '../../../models/wood_database.dart';
import '../../../repository/wood_repository.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState>{
  late final repo = swinLocator<WoodRepository>();

  LibraryBloc() : super(LibraryState()) {
    on<LoadLibraryEvent>(_onLoadLibrary);

    add(LoadLibraryEvent());
  }

  Future<void> _onLoadLibrary(LoadLibraryEvent event, Emitter<LibraryState> emit) async {
    emit(LibraryState(status: BaseStatus.loading));

    try {
      await Future.delayed(Duration(seconds: 2));
      final result = await repo.getWoodDatabases();

      emit(LibraryState(status: BaseStatus.success, databases: result));
    } catch (e) {
      emit(LibraryState(
        status: BaseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
