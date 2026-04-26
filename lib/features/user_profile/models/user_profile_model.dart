enum ProfileType {
  student,
  professional,
}

class UserProfile {
  final String id;
  final String name;
  final ProfileType profileType;
  final int defaultWorkHours;
  final int currentStreak;
  final DateTime? lastUpdateDate;
  final String? profileImageUrl;

  UserProfile({
    required this.id,
    required this.name,
    this.profileType = ProfileType.student,
    this.defaultWorkHours = 0,
    this.currentStreak = 0,
    this.lastUpdateDate,
    this.profileImageUrl,
  });

  UserProfile copyWith({
    String? name,
    ProfileType? profileType,
    int? defaultWorkHours,
    int? currentStreak,
    DateTime? lastUpdateDate,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      profileType: profileType ?? this.profileType,
      defaultWorkHours: defaultWorkHours ?? this.defaultWorkHours,
      currentStreak: currentStreak ?? this.currentStreak,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
