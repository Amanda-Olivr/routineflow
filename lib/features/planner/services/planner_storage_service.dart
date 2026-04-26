import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de persistência para tarefas e notas do Planner Semanal.
/// Usa SharedPreferences (compatível com Web, Android, iOS).
class PlannerStorageService {
  static const String _tasksKey = 'planner_weekly_tasks';
  static const String _notesKey = 'planner_daily_notes';

  // ── Tarefas ──────────────────────────────────────────────────────────────

  /// Salva o mapa completo de tarefas semanais.
  Future<void> saveTasks(Map<String, List<Map<String, dynamic>>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(tasks);
    await prefs.setString(_tasksKey, json);
  }

  /// Carrega as tarefas semanais. Retorna null se não houver dados salvos.
  Future<Map<String, List<Map<String, dynamic>>>?> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_tasksKey);
    if (json == null) return null;

    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((key, value) {
      final list = (value as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      return MapEntry(key, list);
    });
  }

  // ── Notas diárias ────────────────────────────────────────────────────────

  /// Salva as notas diárias.
  Future<void> saveNotes(Map<String, String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(notes);
    await prefs.setString(_notesKey, json);
  }

  /// Carrega as notas diárias. Retorna null se não houver dados salvos.
  Future<Map<String, String>?> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_notesKey);
    if (json == null) return null;

    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  /// Remove todos os dados do planner.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_notesKey);
  }
}
