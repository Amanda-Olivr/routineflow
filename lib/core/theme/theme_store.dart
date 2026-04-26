import 'package:mobx/mobx.dart';
import '../../features/user_profile/services/user_storage_service.dart';

part 'theme_store.g.dart';

class ThemeStore = _ThemeStoreBase with _$ThemeStore;

enum AppThemeMode { light, dark, highContrast }

abstract class _ThemeStoreBase with Store {
  final UserStorageService _storage = UserStorageService();

  @observable
  AppThemeMode currentMode = AppThemeMode.light;

  @action
  Future<void> init() async {
    final savedMode = await _storage.loadThemeMode();
    if (savedMode != null) {
      currentMode = AppThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => AppThemeMode.light,
      );
    }
  }

  @action
  Future<void> setThemeMode(AppThemeMode mode) async {
    currentMode = mode;
    await _storage.saveThemeMode(mode.toString());
  }
}
