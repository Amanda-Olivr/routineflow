import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../controllers/routine_controller.dart';
import '../stores/routine_store.dart';
import '../models/study_session_model.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  final RoutineController controller;
  final RoutineStore store;

  const DashboardScreen({Key? key, required this.controller, required this.store}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadTodayRoutine();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boa noite, Amanda', style: theme.textTheme.headlineMedium),
            Text('Aqui está o seu foco para hoje', style: theme.textTheme.bodyMedium),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Observer(
        builder: (_) {
          if (widget.store.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.primary),
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
                                backgroundColor: AppTheme.primary.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(widget.store.progressPercentage * 100).toInt()}%',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary),
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

    return Card(
      elevation: isDone ? 1 : 4,
      color: isDone ? AppTheme.surface.withOpacity(0.6) : AppTheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDone ? AppTheme.primary.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDone ? AppTheme.primary.withOpacity(0.2) : AppTheme.secondary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.book_outlined,
            color: isDone ? AppTheme.primary : AppTheme.alertSoft,
          ),
        ),
        title: Text(
          session.subject,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          '${session.duration.inMinutes} min • Hoje ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDone ? AppTheme.textSecondary.withOpacity(0.7) : AppTheme.textSecondary,
          ),
        ),
        trailing: Checkbox(
          value: isDone,
          onChanged: (val) {
            if (val == true) {
              widget.controller.markSessionCompleted(session);
            } else {
              widget.controller.failSession(session, 8);
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
          color: AppTheme.background,
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
                color: AppTheme.secondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.self_improvement, size: 32, color: AppTheme.alertSoft),
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
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Call logic to actually move to tomorrow
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
                  // Call logic to move to weekend
                },
                child: const Text('Deixar para o fim de semana'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
