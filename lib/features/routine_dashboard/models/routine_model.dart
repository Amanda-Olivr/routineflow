import 'study_session_model.dart';

class Routine {
  final String id;
  final DateTime date;
  final List<StudySession> studySessions;
  final int workHoursRemaining;

  Routine({
    required this.id,
    required this.date,
    required this.studySessions,
    required this.workHoursRemaining,
  });
}
