import '../models/study_session_model.dart';

class RoutineSuggestionService {
  /// Sugere uma nova janela de tempo para o aluno que perdeu a sessão.
  StudySession suggestReschedule(StudySession missedSession, int workHoursLeft) {
    // Regra simples: Se o aluno trabalha muito hoje, joga pra amanhã cedo.
    // Se trabalha pouco, tenta realocar para o fim da noite.
    if (workHoursLeft > 6) {
      return missedSession.copyWith(
        startTime: DateTime.now().add(const Duration(days: 1, hours: 7)), // 7 AM amanhã
      );
    } else {
      return missedSession.copyWith(
        startTime: DateTime.now().copyWith(hour: 22), // 22 PM hoje
      );
    }
  }
}
