import '../stores/routine_store.dart';
import '../services/routine_suggestion_service.dart';
import '../../../services/local_storage_service.dart';
import '../models/study_session_model.dart';
import '../../user_profile/stores/user_store.dart';
import '../../user_profile/services/routine_generation_service.dart';

class RoutineController {
  final RoutineStore _store;
  final LocalStorageService _storageService;
  final RoutineSuggestionService _suggestionService;
  final UserStore _userStore;
  final RoutineGenerationService _generationService;

  RoutineController(
    this._store, 
    this._storageService, 
    this._suggestionService,
    this._userStore,
    this._generationService,
  );

  Future<void> loadTodayRoutine() async {
    _store.setLoading(true);
    try {
      // In a real app we'd load from DB. Here we use the generator based on profile.
      final sessions = _generationService.generateDailyRoutine(_userStore.profile);
      _store.setSessions(sessions);
    } finally {
      _store.setLoading(false);
    }
  }

  Future<void> markSessionCompleted(StudySession session) async {
    final updated = session.copyWith(isCompleted: true);
    await _storageService.updateSessionStatus(updated.id, true);
    _store.updateSession(updated);
    
    // Register activity to keep streak alive
    _userStore.registerActivity();
  }

  Future<void> failSession(StudySession session) async {
    // 1. Marca como não concluída
    await _storageService.updateSessionStatus(session.id, false);
    
    // 2. Aciona o serviço para obter sugestão de replanejamento usando as horas do perfil
    final suggestion = _suggestionService.suggestReschedule(session, _userStore.profile.defaultWorkHours);
    
    // 3. Atualiza na store local
    _store.updateSession(suggestion);
    
    // Registrar atividade! Falhar e replanejar também conta como vitória de organização e mantém o streak!
    _userStore.registerActivity();
  }
}
