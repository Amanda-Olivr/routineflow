import '../features/routine_dashboard/models/study_session_model.dart';

abstract class LocalStorageService {
  Future<void> saveSession(StudySession session);
  Future<List<StudySession>> getSessionsForDate(DateTime date);
  Future<void> updateSessionStatus(String sessionId, bool isCompleted);
}

class HiveStorageService implements LocalStorageService {
  @override
  Future<List<StudySession>> getSessionsForDate(DateTime date) async {
    // Mocking return value
    return [
      StudySession(
        id: '1', 
        subject: 'Matemática Discreta', 
        startTime: DateTime.now(), 
        duration: const Duration(minutes: 45)
      ),
      StudySession(
        id: '2', 
        subject: 'Engenharia de Software', 
        startTime: DateTime.now().add(const Duration(hours: 2)), 
        duration: const Duration(minutes: 60)
      ),
    ];
  }

  @override
  Future<void> saveSession(StudySession session) async {
    // Mock implementation
  }

  @override
  Future<void> updateSessionStatus(String sessionId, bool isCompleted) async {
    // Mock implementation
  }
}
