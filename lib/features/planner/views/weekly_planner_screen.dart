import 'package:flutter/material.dart';
import '../services/planner_storage_service.dart';

class PlannerTask {
  final String id;
  String title;
  bool isCompleted;
  String time;

  PlannerTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.time = 'Livre',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'time': time,
  };

  factory PlannerTask.fromMap(Map<String, dynamic> map) => PlannerTask(
    id: map['id'] as String,
    title: map['title'] as String,
    isCompleted: map['isCompleted'] as bool? ?? false,
    time: map['time'] as String? ?? 'Livre',
  );
}

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({Key? key}) : super(key: key);

  @override
  _WeeklyPlannerScreenState createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PlannerStorageService _storage = PlannerStorageService();
  bool _isLoaded = false;

  final List<String> _shortDays = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom'
  ];
  final List<String> _fullDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  // Dados padrão (usados apenas na primeira vez)
  final Map<String, List<PlannerTask>> _weeklyTasks = {
    'Segunda-feira': [],
    'Terça-feira': [],
    'Quarta-feira': [],
    'Quinta-feira': [],
    'Sexta-feira': [],
    'Sábado': [],
    'Domingo': [],
  };

  /// Notas rápidas por dia da semana
  final Map<String, String> _dailyNotes = {
    'Segunda-feira': '',
    'Terça-feira': '',
    'Quarta-feira': '',
    'Quinta-feira': '',
    'Sexta-feira': '',
    'Sábado': '',
    'Domingo': '',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadFromStorage();
  }

  /// Carrega tarefas e notas do armazenamento local.
  Future<void> _loadFromStorage() async {
    // Tarefas
    final savedTasks = await _storage.loadTasks();
    if (savedTasks != null) {
      for (final day in _fullDays) {
        final taskMaps = savedTasks[day];
        if (taskMaps != null) {
          _weeklyTasks[day] = taskMaps.map((m) => PlannerTask.fromMap(m)).toList();
        }
      }
    } else {
      // Primeira vez: criar dados de exemplo
      _weeklyTasks['Segunda-feira'] = [
        PlannerTask(id: '1', title: 'Matemática (Capítulo 3)', time: 'Manhã'),
        PlannerTask(id: '2', title: 'Física (Exercícios)', time: 'Tarde'),
      ];
      _weeklyTasks['Terça-feira'] = [
        PlannerTask(id: '3', title: 'História (Resumo)', time: 'Manhã'),
        PlannerTask(id: '4', title: 'Inglês (Reading)', time: 'Noite'),
      ];
      _weeklyTasks['Quarta-feira'] = [
        PlannerTask(id: '5', title: 'Biologia (Genética)', time: 'Tarde'),
      ];
      _weeklyTasks['Quinta-feira'] = [
        PlannerTask(id: '6', title: 'Redação (Prática)', time: 'Manhã'),
      ];
      _weeklyTasks['Sexta-feira'] = [
        PlannerTask(id: '7', title: 'Revisão Geral', time: 'Tarde'),
      ];
      _weeklyTasks['Domingo'] = [
        PlannerTask(id: '8', title: 'Organizar semana', time: 'Noite', isCompleted: true),
      ];
      _persistTasks(); // Salva os dados de exemplo
    }

    // Notas
    final savedNotes = await _storage.loadNotes();
    if (savedNotes != null) {
      for (final day in _fullDays) {
        _dailyNotes[day] = savedNotes[day] ?? '';
      }
    }

    if (mounted) {
      setState(() => _isLoaded = true);
    }
  }

  /// Persiste o mapa de tarefas no armazenamento local.
  void _persistTasks() {
    final serialized = _weeklyTasks.map((day, tasks) =>
      MapEntry(day, tasks.map((t) => t.toMap()).toList()),
    );
    _storage.saveTasks(serialized);
  }

  /// Persiste as notas no armazenamento local.
  void _persistNotes() {
    _storage.saveNotes(Map<String, String>.from(_dailyNotes));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Notes
  // ──────────────────────────────────────────────────────────────────────────

  void _showNoteEditor(String day) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: _dailyNotes[day]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Icon(Icons.sticky_note_2_rounded,
                        color: theme.colorScheme.secondary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Nota — $day',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Text field
                TextField(
                  controller: controller,
                  maxLines: 5,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:
                        'Ex: Lembrar de revisar o capítulo 4 antes do simulado...',
                    hintStyle:
                        TextStyle(color: theme.hintColor, fontSize: 13),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.dividerColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: theme.primaryColor, width: 1.5),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    // Clear note
                    if ((_dailyNotes[day] ?? '').isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _dailyNotes[day] = '');
                          _persistNotes();
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        label: const Text('Apagar',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(
                            () => _dailyNotes[day] = controller.text.trim());
                        _persistNotes();
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tasks
  // ──────────────────────────────────────────────────────────────────────────

  // Matérias sugeridas para atalho rápido
  static const List<String> _quickSubjects = [
    'Matemática',
    'Português',
    'História',
    'Geografia',
    'Física',
    'Química',
    'Biologia',
    'Inglês',
    'Redação',
    'Filosofia',
    'Sociologia',
    'Revisão Geral',
  ];

  void _showAddTaskSheet(String day) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    String selectedTime = 'Livre';
    final times = ['Manhã', 'Tarde', 'Noite', 'Livre'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Título
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add_task_rounded, color: theme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nova Tarefa', style: theme.textTheme.titleLarge),
                            Text(day, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campo de texto
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ex: Matemática — Capítulo 5, Redação...',
                        prefixIcon: Icon(Icons.edit_note_rounded, color: theme.primaryColor),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Atalhos de matéria
                    Text('Atalhos rápidos', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _quickSubjects.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final s = _quickSubjects[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              titleController.text = s;
                              titleController.selection = TextSelection.fromPosition(
                                TextPosition(offset: s.length),
                              );
                              setModalState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
                              ),
                              child: Text(
                                s,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Seletor de turno
                    Text('Turno', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: times.map((t) {
                        final isSelected = t == selectedTime;
                        final icons = {
                          'Manhã': Icons.wb_sunny_rounded,
                          'Tarde': Icons.wb_cloudy_rounded,
                          'Noite': Icons.nightlight_round,
                          'Livre': Icons.access_time_rounded,
                        };
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setModalState(() => selectedTime = t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.primaryColor
                                        : theme.colorScheme.outline.withOpacity(0.4),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      icons[t]!,
                                      size: 18,
                                      color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Botão de salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: titleController.text.trim().isEmpty
                            ? null
                            : () {
                                final newTask = PlannerTask(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: titleController.text.trim(),
                                  time: selectedTime,
                                );
                                setState(() {
                                  _weeklyTasks[day]?.add(newTask);
                                });
                                _persistTasks();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${newTask.title}" adicionada a $day'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('Adicionar Tarefa'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _moveTask(
      PlannerTask task, String fromDay, String toDay, String newTime) {
    setState(() {
      _weeklyTasks[fromDay]?.removeWhere((t) => t.id == task.id);
      task.time = newTime;
      _weeklyTasks[toDay]?.add(task);
    });
    _persistTasks();
  }

  void _showEditOptions(PlannerTask task, String currentDay) {
    String selectedDay = currentDay;
    String selectedTime = task.time;
    final times = ['Manhã', 'Tarde', 'Noite', 'Livre'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          final theme = Theme.of(context);
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reorganizar Meta', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),

                // Escolher Dia
                Text('Para qual dia?', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _fullDays.map((day) {
                    final isSelected = day == selectedDay;
                    return ChoiceChip(
                      label: Text(day.split('-')[0]),
                      selected: isSelected,
                      selectedColor: theme.primaryColor.withOpacity(0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            selectedDay = day;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Escolher Horário
                Text('Em qual horário/turno?',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: times.map((t) {
                    final isSelected = t == selectedTime;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      selectedColor:
                          theme.colorScheme.secondary.withOpacity(0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {
                            selectedTime = t;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Botões de Ação
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _weeklyTasks[currentDay]
                                ?.removeWhere((t) => t.id == task.id);
                          });
                          _persistTasks();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Remover',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _moveTask(
                              task, currentDay, selectedDay, selectedTime);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Salvar Alteração'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleTaskStatus(PlannerTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _persistTasks();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Note card widget
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildNoteCard(String day, ThemeData theme) {
    final note = _dailyNotes[day] ?? '';
    final hasNote = note.isNotEmpty;

    return GestureDetector(
      onTap: () => _showNoteEditor(day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasNote
              ? theme.colorScheme.secondary.withOpacity(0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasNote
                ? theme.colorScheme.secondary.withOpacity(0.4)
                : theme.dividerColor.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasNote
                  ? Icons.sticky_note_2_rounded
                  : Icons.note_add_outlined,
              color: hasNote
                  ? theme.colorScheme.secondary
                  : theme.hintColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: hasNote
                  ? Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      'Adicionar nota para este dia…',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_outlined,
                size: 16,
                color: hasNote
                    ? theme.colorScheme.secondary
                    : theme.hintColor.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  // Cores por matéria — mesma paleta do dashboard
  static const List<Color> _subjectColors = [
    Color(0xFF4F46E5),
    Color(0xFF0D9488),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  Color _colorForIndex(int i) => _subjectColors[i % _subjectColors.length];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Planner Semanal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_isLoaded
          ? Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
                strokeWidth: 3,
              ),
            )
          : Column(
              children: [
          // ── Banner Motivacional ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Todo passo conta!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '15 min focados valem muito. Celebre cada conquista!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.88),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── TabBar ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: theme.textTheme.bodySmall?.color,
              labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: theme.textTheme.labelMedium,
              tabs: _shortDays.map((d) => Tab(text: d)).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // ── Conteúdo das Abas ────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _fullDays.map((day) {
                final tasks = _weeklyTasks[day] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNoteCard(day, theme),
                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available_rounded,
                                    size: 64,
                                    color: theme.colorScheme.outline.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Sem metas para $day.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Toque em + para adicionar',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                final accent = _colorForIndex(index);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    decoration: BoxDecoration(
                                      color: task.isCompleted
                                          ? theme.colorScheme.surface.withOpacity(isDark ? 0.5 : 0.7)
                                          : theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                        width: 1.2,
                                      ),
                                      boxShadow: task.isCompleted || isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: accent.withOpacity(0.07),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              )
                                            ],
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          // Barra lateral colorida
                                          Container(
                                            width: 5,
                                            decoration: BoxDecoration(
                                              color: task.isCompleted
                                                  ? accent.withOpacity(0.3)
                                                  : accent,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(18),
                                                bottomLeft: Radius.circular(18),
                                              ),
                                            ),
                                          ),
                                          // Checkbox
                                          Checkbox(
                                            value: task.isCompleted,
                                            activeColor: accent,
                                            side: BorderSide(color: accent.withOpacity(0.5), width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            onChanged: (_) => _toggleTaskStatus(task),
                                          ),
                                          // Conteúdo
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    task.title,
                                                    style: theme.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      decoration: task.isCompleted
                                                          ? TextDecoration.lineThrough
                                                          : null,
                                                      color: task.isCompleted
                                                          ? theme.colorScheme.onSurface.withOpacity(0.4)
                                                          : theme.colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.schedule_rounded,
                                                        size: 12,
                                                        color: theme.colorScheme.secondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        task.time,
                                                        style: theme.textTheme.bodySmall?.copyWith(
                                                          color: theme.colorScheme.secondary,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Menu
                                          IconButton(
                                            icon: Icon(
                                              Icons.more_vert_rounded,
                                              color: theme.colorScheme.outline,
                                              size: 20,
                                            ),
                                            onPressed: () => _showEditOptions(task, day),
                                            tooltip: 'Reorganizar',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentDay = _fullDays[_tabController.index];
          _showAddTaskSheet(currentDay);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar'),
      ),
    );
  }
}
