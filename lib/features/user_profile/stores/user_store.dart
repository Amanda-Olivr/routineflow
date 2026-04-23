import 'package:mobx/mobx.dart';
import '../models/user_profile_model.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  @observable
  UserProfile profile = UserProfile(
    id: 'user1',
    name: 'Amanda',
    profileType: ProfileType.student,
    defaultWorkHours: 0,
    currentStreak: 0,
  );

  @action
  void setProfileType(ProfileType type) {
    int workHours = type == ProfileType.professional ? 8 : 0;
    profile = profile.copyWith(profileType: type, defaultWorkHours: workHours);
  }

  @action
  void registerActivity() {
    final now = DateTime.now();
    final lastUpdate = profile.lastUpdateDate;
    
    int newStreak = profile.currentStreak;

    if (lastUpdate == null) {
      // First activity ever
      newStreak = 1;
    } else {
      // Check if it's the same day
      bool isSameDay = lastUpdate.year == now.year && 
                       lastUpdate.month == now.month && 
                       lastUpdate.day == now.day;
                       
      if (!isSameDay) {
        // If it's the next day, increment. Otherwise, if it's been more than a day, reset.
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastUpdate.year, lastUpdate.month, lastUpdate.day))
            .inDays;
            
        if (difference == 1) {
          newStreak += 1;
        } else if (difference > 1) {
          // Reset streak if missed a day
          newStreak = 1;
        }
      }
    }

    profile = profile.copyWith(
      currentStreak: newStreak,
      lastUpdateDate: now,
    );
  }
}
