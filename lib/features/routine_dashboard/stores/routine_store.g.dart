// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RoutineStore on _RoutineStoreBase, Store {
  Computed<int>? _$completedSessionsCountComputed;

  @override
  int get completedSessionsCount =>
      (_$completedSessionsCountComputed ??= Computed<int>(
        () => super.completedSessionsCount,
        name: '_RoutineStoreBase.completedSessionsCount',
      )).value;
  Computed<double>? _$progressPercentageComputed;

  @override
  double get progressPercentage =>
      (_$progressPercentageComputed ??= Computed<double>(
        () => super.progressPercentage,
        name: '_RoutineStoreBase.progressPercentage',
      )).value;

  late final _$todaySessionsAtom = Atom(
    name: '_RoutineStoreBase.todaySessions',
    context: context,
  );

  @override
  ObservableList<StudySession> get todaySessions {
    _$todaySessionsAtom.reportRead();
    return super.todaySessions;
  }

  @override
  set todaySessions(ObservableList<StudySession> value) {
    _$todaySessionsAtom.reportWrite(value, super.todaySessions, () {
      super.todaySessions = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_RoutineStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$_RoutineStoreBaseActionController = ActionController(
    name: '_RoutineStoreBase',
    context: context,
  );

  @override
  void setLoading(bool value) {
    final _$actionInfo = _$_RoutineStoreBaseActionController.startAction(
      name: '_RoutineStoreBase.setLoading',
    );
    try {
      return super.setLoading(value);
    } finally {
      _$_RoutineStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSessions(List<StudySession> sessions) {
    final _$actionInfo = _$_RoutineStoreBaseActionController.startAction(
      name: '_RoutineStoreBase.setSessions',
    );
    try {
      return super.setSessions(sessions);
    } finally {
      _$_RoutineStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSession(StudySession updatedSession) {
    final _$actionInfo = _$_RoutineStoreBaseActionController.startAction(
      name: '_RoutineStoreBase.updateSession',
    );
    try {
      return super.updateSession(updatedSession);
    } finally {
      _$_RoutineStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
todaySessions: ${todaySessions},
isLoading: ${isLoading},
completedSessionsCount: ${completedSessionsCount},
progressPercentage: ${progressPercentage}
    ''';
  }
}
