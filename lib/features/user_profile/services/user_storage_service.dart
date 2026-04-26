import 'package:shared_preferences/shared_preferences.dart';

/// Persiste dados do perfil do usuário (streak, tipo de perfil, tema).
class UserStorageService {
  static const String _streakKey = 'user_current_streak';
  static const String _lastUpdateKey = 'user_last_update';
  static const String _profileTypeKey = 'user_profile_type';
  static const String _themeKey = 'user_theme_mode';
  static const String _nameKey = 'user_name';
  static const String _profileImageKey = 'user_profile_image';

  // ── Streak ───────────────────────────────────────────────────────────────

  Future<void> saveStreak(int streak, DateTime lastUpdate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastUpdateKey, lastUpdate.toIso8601String());
  }

  Future<Map<String, dynamic>> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'streak': prefs.getInt(_streakKey) ?? 0,
      'lastUpdate': prefs.getString(_lastUpdateKey),
    };
  }

  // ── Perfil ───────────────────────────────────────────────────────────────

  Future<void> saveProfileType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileTypeKey, type);
  }

  Future<String?> loadProfileType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileTypeKey);
  }

  // ── Tema ─────────────────────────────────────────────────────────────────

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  // ── Nome ─────────────────────────────────────────────────────────────────

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<String?> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  // ── Imagem de Perfil ─────────────────────────────────────────────────────

  Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
  }

  Future<String?> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }
}
