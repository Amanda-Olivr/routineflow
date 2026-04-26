import 'package:mobx/mobx.dart';
import '../models/user_profile_model.dart';
import '../services/user_storage_service.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  final UserStorageService _storage = UserStorageService();

  @observable
  UserProfile profile = UserProfile(
    id: 'user1',
    name: 'Amanda',
    profileType: ProfileType.student,
    defaultWorkHours: 0,
    currentStreak: 0,
  );

  @action
  Future<void> init() async {
    final streakData = await _storage.loadStreak();
    final savedType = await _storage.loadProfileType();
    final savedName = await _storage.loadName();
    final savedImage = await _storage.loadProfileImage();

    ProfileType type = profile.profileType;
    if (savedType != null) {
      type = ProfileType.values.firstWhere(
        (e) => e.toString() == savedType,
        orElse: () => ProfileType.student,
      );
    }

    profile = profile.copyWith(
      name: savedName ?? profile.name,
      profileType: type,
      currentStreak: streakData['streak'] as int,
      lastUpdateDate: streakData['lastUpdate'] != null 
          ? DateTime.parse(streakData['lastUpdate'] as String) 
          : null,
      profileImageUrl: savedImage,
    );
  }

  @action
  Future<void> updateProfileImage(String path) async {
    profile = profile.copyWith(profileImageUrl: path);
    await _storage.saveProfileImage(path);
  }

  @action
  Future<void> setProfileType(ProfileType type) async {
    int workHours = type == ProfileType.professional ? 8 : 0;
    profile = profile.copyWith(profileType: type, defaultWorkHours: workHours);
    await _storage.saveProfileType(type.toString());
  }

  @action
  Future<void> registerActivity() async {
    final now = DateTime.now();
    final lastUpdate = profile.lastUpdateDate;
    
    int newStreak = profile.currentStreak;

    if (lastUpdate == null) {
      newStreak = 1;
    } else {
      bool isSameDay = lastUpdate.year == now.year && 
                       lastUpdate.month == now.month && 
                       lastUpdate.day == now.day;
                       
      if (!isSameDay) {
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastUpdate.year, lastUpdate.month, lastUpdate.day))
            .inDays;
            
        if (difference == 1) {
          newStreak += 1;
        } else if (difference > 1) {
          newStreak = 1;
        }
      }
    }

    profile = profile.copyWith(
      currentStreak: newStreak,
      lastUpdateDate: now,
    );
    await _storage.saveStreak(newStreak, now);
  }

  @action
  Future<void> setName(String name) async {
    profile = profile.copyWith(name: name);
    await _storage.saveName(name);
  }
}
