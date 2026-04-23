import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../controllers/routine_controller.dart';
import '../stores/routine_store.dart';
import '../models/study_session_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_store.dart';
import '../../user_profile/stores/user_store.dart';
import '../../user_profile/models/user_profile_model.dart';

class DashboardScreen extends StatefulWidget {
  final RoutineController controller;
  final RoutineStore store;

  const DashboardScreen({Key? key, required this.controller, required this.store}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ThemeStore _themeStore;
  late UserStore _userStore;

  @override
  void initState() {
    super.initState();
    _themeStore = GetIt.I<ThemeStore>();
    _userStore = GetIt.I<UserStore>();
    widget.controller.loadTodayRoutine();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Boa noite, ${_userStore.profile.name}', style: theme.textTheme.headlineMedium),
              Text('Aqui está o seu foco para hoje', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Observer(
              builder: (_) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${_userStore.profile.currentStreak}',
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        toolbarHeight: 80,
      ),
      drawer: _buildDrawer(context),
      body: Observer(
        builder: (_) {
          if (widget.store.isLoading) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progresso diário',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.store.progressPercentage,
                                minHeight: 6,
                                backgroundColor: theme.primaryColor.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(widget.store.progressPercentage * 100).toInt()}%',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text('Sessões de Estudo', style: theme.textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  itemCount: widget.store.todaySessions.length,
                  itemBuilder: (_, index) {
                    final session = widget.store.todaySessions[index];
                    return _buildSessionCard(context, session);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, StudySession session) {
    final theme = Theme.of(context);
    final isDone = session.isCompleted;
    final isHighContrast = _themeStore.currentMode == AppThemeMode.highContrast;

    return Card(
      elevation: isDone && !isHighContrast ? 1 : (isHighContrast ? 0 : 4),
      color: isDone && !isHighContrast ? theme.colorScheme.surface.withOpacity(0.6) : theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isHighContrast 
              ? Colors.white 
              : (isDone ? theme.primaryColor.withOpacity(0.3) : Colors.transparent),
          width: isHighContrast ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDone 
                ? theme.primaryColor.withOpacity(0.2) 
                : theme.colorScheme.secondary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.book_outlined,
            color: isDone ? theme.primaryColor : theme.colorScheme.error,
          ),
        ),
        title: Text(
          session.subject,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${session.duration.inMinutes} min • Hoje ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDone ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5) : theme.textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Checkbox(
          value: isDone,
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
    );
  }

  void _showRescheduleDialog(BuildContext context, StudySession session) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.self_improvement, size: 32, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 24),
            Text(
              'Parece que o dia foi puxado...',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Você não conseguiu focar em ${session.subject} agora, mas está tudo bem. Cansaço faz parte da rotina. Vamos ajustar?',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Mover para amanhã cedo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Deixar para o fim de semana'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.person, size: 48, color: theme.primaryColor),
                const SizedBox(height: 8),
                Observer(
                  builder: (_) => Text(
                    _userStore.profile.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                Observer(
                  builder: (_) => Text(
                    _userStore.profile.profileType == ProfileType.student 
                        ? 'Perfil: Estudante' 
                        : 'Perfil: Profissional',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Perfil', style: theme.textTheme.titleLarge),
          ),
          Observer(
            builder: (_) => RadioListTile<ProfileType>(
              title: const Text('Estudante Integral'),
              subtitle: const Text('Mais sessões ao longo do dia'),
              value: ProfileType.student,
              groupValue: _userStore.profile.profileType,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                if (value != null) {
                  _userStore.setProfileType(value);
                  widget.controller.loadTodayRoutine(); // Recarrega com a nova rotina gerada
                }
              },
            ),
          ),
          Observer(
            builder: (_) => RadioListTile<ProfileType>(
              title: const Text('Profissional (Trabalha 8h)'),
              subtitle: const Text('Sessões curtas e focadas'),
              value: ProfileType.professional,
              groupValue: _userStore.profile.profileType,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                if (value != null) {
                  _userStore.setProfileType(value);
                  widget.controller.loadTodayRoutine(); // Recarrega com a nova rotina gerada
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text('Aparência', style: theme.textTheme.titleLarge),
          ),
          Observer(
            builder: (_) => RadioListTile<AppThemeMode>(
              title: const Text('Tema Claro (Anti-Burnout)'),
              value: AppThemeMode.light,
              groupValue: _themeStore.currentMode,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                if (value != null) _themeStore.setThemeMode(value);
              },
            ),
          ),
          Observer(
            builder: (_) => RadioListTile<AppThemeMode>(
              title: const Text('Tema Escuro'),
              value: AppThemeMode.dark,
              groupValue: _themeStore.currentMode,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                if (value != null) _themeStore.setThemeMode(value);
              },
            ),
          ),
          Observer(
            builder: (_) => RadioListTile<AppThemeMode>(
              title: const Text('Alto Contraste'),
              value: AppThemeMode.highContrast,
              groupValue: _themeStore.currentMode,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                if (value != null) _themeStore.setThemeMode(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
