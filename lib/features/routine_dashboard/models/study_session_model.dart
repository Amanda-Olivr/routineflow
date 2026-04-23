class StudySession {
  final String id;
  final String subject;
  final DateTime startTime;
  final Duration duration;
  final bool isCompleted;

  StudySession({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.duration,
    this.isCompleted = false,
  });

  StudySession copyWith({
    String? id,
    String? subject,
    DateTime? startTime,
    Duration? duration,
    bool? isCompleted,
  }) {
    return StudySession(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
