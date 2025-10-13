import 'package:get_it/get_it.dart';
import 'package:swin/repository/model_repository.dart';

final swinLocator = GetIt.instance;

void initSwinLocator() {
  // Register services, repositories, blocs, etc. here
  swinLocator.registerLazySingleton<ModelRepository>(() => ModelRepository());
}