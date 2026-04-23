import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

class ThemeStore = _ThemeStoreBase with _$ThemeStore;

enum AppThemeMode { light, dark, highContrast }

abstract class _ThemeStoreBase with Store {
  @observable
  AppThemeMode currentMode = AppThemeMode.light;

  @action
  void setThemeMode(AppThemeMode mode) {
    currentMode = mode;
  }
}
