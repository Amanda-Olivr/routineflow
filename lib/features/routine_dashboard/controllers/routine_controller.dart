import '../stores/routine_store.dart';
import '../services/routine_suggestion_service.dart';
import '../../../services/local_storage_service.dart';
import '../models/study_session_model.dart';

class RoutineController {
  final RoutineStore _store;
  final LocalStorageService _storageService;
  final RoutineSuggestionService _suggestionService;

  RoutineController(this._store, this._storageService, this._suggestionService);

  Future<void> loadTodayRoutine() async {
    _store.setLoading(true);
    try {
      final sessions = await _storageService.getSessionsForDate(DateTime.now());
      _store.setSessions(sessions);
    } finally {
      _store.setLoading(false);
    }
  }

  Future<void> markSessionCompleted(StudySession session) async {
    final updated = session.copyWith(isCompleted: true);
    await _storageService.updateSessionStatus(updated.id, true);
    _store.updateSession(updated);
  }

  Future<void> failSession(StudySession session, int currentWorkHours) async {
    // 1. Marca como não concluída (ou falha)
    await _storageService.updateSessionStatus(session.id, false);
    
    // 2. Aciona o serviço para obter sugestão de replanejamento
    final suggestion = _suggestionService.suggestReschedule(session, currentWorkHours);
    
    // 3. Adicionar a sugestão à Store ou algo similar (mock de comportamento)
    // Para fins do MVP, vamos apenas atualizar a sessão com a sugestão localmente na store
    _store.updateSession(suggestion);
  }
}
