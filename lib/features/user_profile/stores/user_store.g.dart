// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStoreBase, Store {
  late final _$profileAtom = Atom(
    name: '_UserStoreBase.profile',
    context: context,
  );

  @override
  UserProfile get profile {
    _$profileAtom.reportRead();
    return super.profile;
  }

  @override
  set profile(UserProfile value) {
    _$profileAtom.reportWrite(value, super.profile, () {
      super.profile = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    '_UserStoreBase.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$updateProfileImageAsyncAction = AsyncAction(
    '_UserStoreBase.updateProfileImage',
    context: context,
  );

  @override
  Future<void> updateProfileImage(String path) {
    return _$updateProfileImageAsyncAction.run(
      () => super.updateProfileImage(path),
    );
  }

  late final _$setProfileTypeAsyncAction = AsyncAction(
    '_UserStoreBase.setProfileType',
    context: context,
  );

  @override
  Future<void> setProfileType(ProfileType type) {
    return _$setProfileTypeAsyncAction.run(() => super.setProfileType(type));
  }

  late final _$registerActivityAsyncAction = AsyncAction(
    '_UserStoreBase.registerActivity',
    context: context,
  );

  @override
  Future<void> registerActivity() {
    return _$registerActivityAsyncAction.run(() => super.registerActivity());
  }

  late final _$setNameAsyncAction = AsyncAction(
    '_UserStoreBase.setName',
    context: context,
  );

  @override
  Future<void> setName(String name) {
    return _$setNameAsyncAction.run(() => super.setName(name));
  }

  @override
  String toString() {
    return '''
profile: ${profile}
    ''';
  }
}
