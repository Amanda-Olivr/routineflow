import 'package:flutter/material.dart';

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
}

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({Key? key}) : super(key: key);

  @override
  _WeeklyPlannerScreenState createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _shortDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  final List<String> _fullDays = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 
    'Sexta-feira', 'Sábado', 'Domingo'
  ];

  final Map<String, List<PlannerTask>> _weeklyTasks = {
    'Segunda-feira': [
      PlannerTask(id: '1', title: 'Matemática (Capítulo 3)', time: 'Manhã'),
      PlannerTask(id: '2', title: 'Física (Exercícios)', time: 'Tarde'),
    ],
    'Terça-feira': [
      PlannerTask(id: '3', title: 'História (Resumo)', time: 'Manhã'),
      PlannerTask(id: '4', title: 'Inglês (Reading)', time: 'Noite'),
    ],
    'Quarta-feira': [
      PlannerTask(id: '5', title: 'Biologia (Genética)', time: 'Tarde'),
    ],
    'Quinta-feira': [
      PlannerTask(id: '6', title: 'Redação (Prática)', time: 'Manhã'),
    ],
    'Sexta-feira': [
      PlannerTask(id: '7', title: 'Revisão Geral', time: 'Tarde'),
    ],
    'Sábado': [],
    'Domingo': [
      PlannerTask(id: '8', title: 'Organizar semana', time: 'Noite', isCompleted: true),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Inicia na segunda-feira por padrão, ou poderia ser o dia atual
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _moveTask(PlannerTask task, String fromDay, String toDay, String newTime) {
    setState(() {
      _weeklyTasks[fromDay]?.removeWhere((t) => t.id == task.id);
      task.time = newTime;
      _weeklyTasks[toDay]?.add(task);
    });
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                Text('Em qual horário/turno?', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: times.map((t) {
                    final isSelected = t == selectedTime;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.secondary.withOpacity(0.3),
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
                            _weeklyTasks[currentDay]?.removeWhere((t) => t.id == task.id);
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Remover', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _moveTask(task, currentDay, selectedDay, selectedTime);
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
        }
      ),
    );
  }

  void _toggleTaskStatus(PlannerTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner Semanal'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner Motivacional (Mantido e ajustado)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Todo passo conta!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '15 minutos focados valem muito! Adapte sua rotina real, celebre suas conquistas do dia a dia e persista! 🚀',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // TabBar dos Dias da Semana
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.hintColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: _shortDays.map((day) => Tab(text: day)).toList(),
          ),

          // Conteúdo das Abas (To-Do List por dia)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _fullDays.map((day) {
                final tasks = _weeklyTasks[day] ?? [];
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 64, color: theme.hintColor.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Sem metas para $day.',
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: task.isCompleted 
                              ? theme.primaryColor.withOpacity(0.3) 
                              : Colors.transparent,
                        )
                      ),
                      elevation: task.isCompleted ? 0 : 2,
                      color: task.isCompleted 
                          ? theme.colorScheme.surface.withOpacity(0.6) 
                          : theme.colorScheme.surface,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => _toggleTaskStatus(task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted ? theme.hintColor : theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: theme.colorScheme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                task.time,
                                style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert, color: theme.hintColor),
                          onPressed: () => _showEditOptions(task, day),
                          tooltip: 'Reorganizar',
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nova tarefa (em breve!)')),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
