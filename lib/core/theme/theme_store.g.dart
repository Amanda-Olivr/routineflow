// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ThemeStore on _ThemeStoreBase, Store {
  late final _$currentModeAtom = Atom(
    name: '_ThemeStoreBase.currentMode',
    context: context,
  );

  @override
  AppThemeMode get currentMode {
    _$currentModeAtom.reportRead();
    return super.currentMode;
  }

  @override
  set currentMode(AppThemeMode value) {
    _$currentModeAtom.reportWrite(value, super.currentMode, () {
      super.currentMode = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    '_ThemeStoreBase.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$setThemeModeAsyncAction = AsyncAction(
    '_ThemeStoreBase.setThemeMode',
    context: context,
  );

  @override
  Future<void> setThemeMode(AppThemeMode mode) {
    return _$setThemeModeAsyncAction.run(() => super.setThemeMode(mode));
  }

  @override
  String toString() {
    return '''
currentMode: ${currentMode}
    ''';
  }
}
