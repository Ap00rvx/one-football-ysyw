import 'package:get_it/get_it.dart';
import 'package:ysyw/config/debug/debug.dart';
import 'package:ysyw/services/match_data_service.dart';

final locator = GetIt.instance;
void setupLocator() {
  Debug.custom('Setting up service locator...', "LOCATOR ->");
  locator.registerLazySingleton(() => MatchDataService());
}
