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

  late final _$_ThemeStoreBaseActionController = ActionController(
    name: '_ThemeStoreBase',
    context: context,
  );

  @override
  void setThemeMode(AppThemeMode mode) {
    final _$actionInfo = _$_ThemeStoreBaseActionController.startAction(
      name: '_ThemeStoreBase.setThemeMode',
    );
    try {
      return super.setThemeMode(mode);
    } finally {
      _$_ThemeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentMode: ${currentMode}
    ''';
  }
}
