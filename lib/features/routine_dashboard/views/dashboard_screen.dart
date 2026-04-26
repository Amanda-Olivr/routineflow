import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/routine_controller.dart';
import '../stores/routine_store.dart';
import '../models/study_session_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_store.dart';
import '../../user_profile/stores/user_store.dart';
import '../../user_profile/models/user_profile_model.dart';
import '../../pomodoro/views/pomodoro_screen.dart';
import '../../planner/views/weekly_planner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final RoutineController controller;
  final RoutineStore store;

  const DashboardScreen({Key? key, required this.controller, required this.store}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late ThemeStore _themeStore;
  late UserStore _userStore;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // Cores por matéria para dar identidade visual a cada card
  static const List<Color> _subjectColors = [
    Color(0xFF4F46E5), // índigo
    Color(0xFF0D9488), // teal
    Color(0xFFF59E0B), // âmbar
    Color(0xFFEC4899), // rosa
    Color(0xFF8B5CF6), // violeta
    Color(0xFF06B6D4), // ciano
    Color(0xFFEF4444), // vermelho
    Color(0xFF10B981), // esmeralda
  ];

  Color _colorForIndex(int i) => _subjectColors[i % _subjectColors.length];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  void initState() {
    super.initState();
    _themeStore = GetIt.I<ThemeStore>();
    _userStore  = GetIt.I<UserStore>();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    widget.controller.loadTodayRoutine();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      drawer: _buildDrawer(context),
      body: Observer(
        builder: (_) {
          if (widget.store.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
                strokeWidth: 3,
              ),
            );
          }
          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildProgressBanner(theme, isDark)),
                SliverToBoxAdapter(child: _buildSectionHeader(theme)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildSessionCard(
                      context,
                      widget.store.todaySessions[i],
                      i,
                      theme,
                      isDark,
                    ),
                    childCount: widget.store.todaySessions.length,
                  ),
                ),
                SliverToBoxAdapter(child: _buildPomodoroButton(theme)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      await _userStore.updateProfileImage(image.path);
    }
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(Icons.menu_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          tooltip: 'Menu',
        ),
      ),
      title: Observer(
        builder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, ${_userStore.profile.name.split(' ').first} 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Aqui está o seu foco para hoje',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Observer(
            builder: (_) => _StreakBadge(
              streak: _userStore.profile.currentStreak,
              theme: theme,
            ),
          ),
        ),
      ],
      elevation: 0,
    );
  }

  // ── Progress Banner ─────────────────────────────────────────────────────

  Widget _buildProgressBanner(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Observer(
        builder: (_) {
          final pct = widget.store.progressPercentage;
          final done = (pct * widget.store.todaySessions.length).round();
          final total = widget.store.todaySessions.length;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Progresso Diário',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$done / $total sessões',
                        style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pct == 0
                      ? 'Vamos começar! Você consegue 💪'
                      : pct == 1.0
                          ? '🎉 Parabéns! Todas as sessões concluídas!'
                          : '${(pct * 100).toInt()}% concluído — continue assim!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text('Sessões de Hoje', style: theme.textTheme.titleLarge),
          const Spacer(),
          Observer(
            builder: (_) => Text(
              '${widget.store.todaySessions.length} sessões',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ── Session Card ────────────────────────────────────────────────────────

  Widget _buildSessionCard(
    BuildContext context,
    StudySession session,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    final isDone = session.isCompleted;
    final accentColor = _colorForIndex(index);
    final isHC = _themeStore.currentMode == AppThemeMode.highContrast;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDone
              ? theme.colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHC
                ? Colors.white
                : isDone
                    ? theme.colorScheme.outline.withOpacity(0.5)
                    : theme.colorScheme.outline,
            width: isHC ? 2 : 1.2,
          ),
          boxShadow: isDone || isDark || isHC
              ? []
              : [
                  BoxShadow(
                    color: accentColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Barra colorida lateral — identificação visual rápida (Nielsen #6)
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: isDone ? accentColor.withOpacity(0.3) : accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Ícone de matéria
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(isDone ? 0.08 : 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isDone ? Icons.check_circle_rounded : Icons.book_rounded,
                          color: isDone ? accentColor.withOpacity(0.5) : accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Conteúdo textual
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              session.subject,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                color: isDone
                                    ? theme.colorScheme.onSurface.withOpacity(0.45)
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${session.duration.inMinutes} min  •  ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDone
                                        ? theme.colorScheme.onSurface.withOpacity(0.35)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Checkbox
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: isDone,
                          activeColor: accentColor,
                          side: BorderSide(color: accentColor.withOpacity(0.5), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onChanged: (val) {
                            if (val == true) {
                              widget.controller.markSessionCompleted(session);
                            } else {
                              widget.controller.failSession(session);
                              _showRescheduleDialog(context, session);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pomodoro Button ─────────────────────────────────────────────────────

  Widget _buildPomodoroButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PomodoroScreen()),
          ),
          icon: const Icon(Icons.timer_rounded, size: 20),
          label: const Text('Iniciar Sessão Pomodoro'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  // ── Reschedule Dialog ───────────────────────────────────────────────────

  void _showRescheduleDialog(BuildContext context, StudySession session) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.self_improvement_rounded, size: 28, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 20),
            Text('Parece que o dia foi puxado...', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Você não conseguiu focar em ${session.subject} agora, mas está tudo bem. Cansaço faz parte da rotina.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mover para amanhã cedo'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Deixar para o fim de semana'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header do Drawer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Observer(
                        builder: (_) {
                          final imageUrl = _userStore.profile.profileImageUrl;
                          return Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                              image: imageUrl != null
                                  ? DecorationImage(
                                      image: kIsWeb 
                                          ? NetworkImage(imageUrl) 
                                          : FileImage(File(imageUrl)) as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageUrl == null
                                ? const Icon(Icons.person_rounded, size: 32, color: Colors.white)
                                : null,
                          );
                        },
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Observer(
                  builder: (_) => Text(
                    _userStore.profile.name,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                Observer(
                  builder: (_) => Text(
                    _userStore.profile.profileType == ProfileType.student
                        ? '🎓 Estudante'
                        : '💼 Profissional',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Navegação
          _DrawerTile(
            icon: Icons.calendar_month_rounded,
            label: 'Planner Semanal',
            theme: theme,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyPlannerScreen()));
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: theme.colorScheme.outline.withOpacity(0.5)),
          ),

          // Seção Perfil
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text('Perfil', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.8)),
          ),
          Observer(
            builder: (_) => _buildProfileRadio(ProfileType.student, 'Estudante Integral', 'Mais sessões ao longo do dia', theme),
          ),
          Observer(
            builder: (_) => _buildProfileRadio(ProfileType.professional, 'Profissional (8h)', 'Sessões curtas e focadas', theme),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: theme.colorScheme.outline.withOpacity(0.5)),
          ),

          // Seção Aparência
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text('Aparência', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.8)),
          ),
          Observer(builder: (_) => _buildThemeRadio(AppThemeMode.light, '☀️  Tema Claro', theme)),
          Observer(builder: (_) => _buildThemeRadio(AppThemeMode.dark, '🌙  Tema Escuro', theme)),
          Observer(builder: (_) => _buildThemeRadio(AppThemeMode.highContrast, '⚡  Alto Contraste', theme)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileRadio(ProfileType type, String title, String subtitle, ThemeData theme) {
    return RadioListTile<ProfileType>(
      dense: true,
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      value: type,
      groupValue: _userStore.profile.profileType,
      activeColor: theme.primaryColor,
      onChanged: (v) {
        if (v != null) {
          _userStore.setProfileType(v);
          widget.controller.loadTodayRoutine();
        }
      },
    );
  }

  Widget _buildThemeRadio(AppThemeMode mode, String title, ThemeData theme) {
    return RadioListTile<AppThemeMode>(
      dense: true,
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
      value: mode,
      groupValue: _themeStore.currentMode,
      activeColor: theme.primaryColor,
      onChanged: (v) {
        if (v != null) _themeStore.setThemeMode(v);
      },
    );
  }
}

// ── Streak Badge ─────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  final ThemeData theme;
  const _StreakBadge({required this.streak, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelLarge?.copyWith(color: const Color(0xFFF59E0B), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Tile ───────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;
  const _DrawerTile({required this.icon, required this.label, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
      onTap: onTap,
    );
  }
}
