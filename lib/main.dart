import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'services/local_storage_service.dart';
import 'features/routine_dashboard/services/routine_suggestion_service.dart';
import 'features/routine_dashboard/stores/routine_store.dart';
import 'features/routine_dashboard/controllers/routine_controller.dart';
import 'features/routine_dashboard/views/dashboard_screen.dart';
import 'core/theme/app_theme.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<LocalStorageService>(() => HiveStorageService());
  getIt.registerLazySingleton<RoutineSuggestionService>(() => RoutineSuggestionService());
  getIt.registerLazySingleton<RoutineStore>(() => RoutineStore());
  
  getIt.registerFactory<RoutineController>(
    () => RoutineController(
      getIt<RoutineStore>(),
      getIt<LocalStorageService>(),
      getIt<RoutineSuggestionService>(),
    ),
  );
}

void main() {
  setupDependencies();
  runApp(const RoutineFlowApp());
}

class RoutineFlowApp extends StatelessWidget {
  const RoutineFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoutineFlow',
      theme: AppTheme.getTheme(),
      home: DashboardScreen(
        controller: getIt<RoutineController>(),
        store: getIt<RoutineStore>(),
      ),
    );
  }
}
