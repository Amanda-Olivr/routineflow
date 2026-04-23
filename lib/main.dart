import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'services/local_storage_service.dart';
import 'features/routine_dashboard/services/routine_suggestion_service.dart';
import 'features/routine_dashboard/stores/routine_store.dart';
import 'features/routine_dashboard/controllers/routine_controller.dart';
import 'features/routine_dashboard/views/dashboard_screen.dart';
import 'features/user_profile/stores/user_store.dart';
import 'features/user_profile/services/routine_generation_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_store.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<LocalStorageService>(() => HiveStorageService());
  getIt.registerLazySingleton<RoutineSuggestionService>(() => RoutineSuggestionService());
  getIt.registerLazySingleton<RoutineGenerationService>(() => RoutineGenerationService());
  getIt.registerLazySingleton<RoutineStore>(() => RoutineStore());
  getIt.registerLazySingleton<ThemeStore>(() => ThemeStore());
  getIt.registerLazySingleton<UserStore>(() => UserStore());
  
  getIt.registerFactory<RoutineController>(
    () => RoutineController(
      getIt<RoutineStore>(),
      getIt<LocalStorageService>(),
      getIt<RoutineSuggestionService>(),
      getIt<UserStore>(),
      getIt<RoutineGenerationService>(),
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
    final themeStore = getIt<ThemeStore>();

    return Observer(
      builder: (_) {
        return MaterialApp(
          title: 'RoutineFlow',
          theme: AppTheme.getTheme(themeStore.currentMode),
          home: DashboardScreen(
            controller: getIt<RoutineController>(),
            store: getIt<RoutineStore>(),
          ),
        );
      }
    );
  }
}
