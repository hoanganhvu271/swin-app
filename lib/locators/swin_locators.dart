import 'package:get_it/get_it.dart';
import 'package:swin/repository/model_repository.dart';

import '../repository/wood_repository.dart';

final swinLocator = GetIt.instance;

void initSwinLocator() {
  swinLocator.registerLazySingleton<ModelRepository>(() => ModelRepository());
  swinLocator.registerLazySingleton<WoodRepository>(() => WoodRepository());
}