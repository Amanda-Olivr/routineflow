import '../models/user_profile_model.dart';
import '../../routine_dashboard/models/study_session_model.dart';
import 'package:uuid/uuid.dart';

class RoutineGenerationService {
  final _uuid = const Uuid();

  List<StudySession> generateDailyRoutine(UserProfile profile) {
    if (profile.profileType == ProfileType.professional) {
      // Trabalha 8h: Menos sessões, mais curtas e focadas.
      return [
        StudySession(
          id: _uuid.v4(),
          subject: 'Leitura Focada (Técnica)',
          startTime: DateTime.now().copyWith(hour: 20, minute: 0),
          duration: const Duration(minutes: 25),
        ),
        StudySession(
          id: _uuid.v4(),
          subject: 'Revisão Rápida',
          startTime: DateTime.now().copyWith(hour: 20, minute: 30),
          duration: const Duration(minutes: 15),
        ),
      ];
    } else {
      // Estudante integral: Mais sessões
      return [
        StudySession(
          id: _uuid.v4(),
          subject: 'Aula Principal',
          startTime: DateTime.now().copyWith(hour: 14, minute: 0),
          duration: const Duration(hours: 1),
        ),
        StudySession(
          id: _uuid.v4(),
          subject: 'Exercícios Práticos',
          startTime: DateTime.now().copyWith(hour: 15, minute: 30),
          duration: const Duration(minutes: 45),
        ),
        StudySession(
          id: _uuid.v4(),
          subject: 'Leitura Complementar',
          startTime: DateTime.now().copyWith(hour: 17, minute: 0),
          duration: const Duration(minutes: 30),
        ),
      ];
    }
  }
}
