import 'package:mobx/mobx.dart';
import '../models/study_session_model.dart';

part 'routine_store.g.dart';

class RoutineStore = _RoutineStoreBase with _$RoutineStore;

abstract class _RoutineStoreBase with Store {
  @observable
  ObservableList<StudySession> todaySessions = ObservableList<StudySession>();

  @observable
  bool isLoading = false;

  @computed
  int get completedSessionsCount => 
      todaySessions.where((s) => s.isCompleted).length;

  @computed
  double get progressPercentage => todaySessions.isEmpty 
      ? 0.0 
      : completedSessionsCount / todaySessions.length;

  @action
  void setLoading(bool value) => isLoading = value;

  @action
  void setSessions(List<StudySession> sessions) {
    todaySessions.clear();
    todaySessions.addAll(sessions);
  }

  @action
  void updateSession(StudySession updatedSession) {
    final index = todaySessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      todaySessions[index] = updatedSession;
    }
  }
}
