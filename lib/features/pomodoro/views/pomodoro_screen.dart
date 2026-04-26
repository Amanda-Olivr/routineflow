import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Intervalos padrão: 25 min foco, 5 min pausa
  static const int _focusTimeInSeconds = 25 * 60;
  static const int _breakTimeInSeconds = 5 * 60;

  final List<double> _studyOptions = [1.0, 1.5, 2.0, 2.5, 3.0, 4.0];
  double _selectedStudyHours = 1.0;

  late int _totalCycles;
  int _currentCycle = 1;
  bool _isBreakTime = false;

  late int _remainingTimeInSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _setupCycles();
  }

  void _setupCycles() {
    // 1 hora = 60 minutos = 2 ciclos de 30 min (25 foco + 5 pausa)
    _totalCycles = (_selectedStudyHours * 2).toInt();
    _currentCycle = 1;
    _isBreakTime = false;
    _remainingTimeInSeconds = _focusTimeInSeconds;
    _isRunning = false;
    if (_timer != null) _timer!.cancel();
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (_remainingTimeInSeconds > 0) {
      setState(() {
        _remainingTimeInSeconds--;
      });
    } else {
      // Terminou o tempo atual
      if (!_isBreakTime) {
        // Terminou o foco
        if (_currentCycle >= _totalCycles) {
          // Terminou todos os ciclos
          _stopTimer();
          _showCompletionDialog();
        } else {
          // Vai para a pausa
          setState(() {
            _isBreakTime = true;
            _remainingTimeInSeconds = _breakTimeInSeconds;
          });
        }
      } else {
        // Terminou a pausa, volta pro foco
        setState(() {
          _isBreakTime = false;
          _currentCycle++;
          _remainingTimeInSeconds = _focusTimeInSeconds;
        });
      }
    }
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _setupCycles();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Parabéns! 🎉'),
        content: Text('Você concluiu sua meta de estudo de ${_selectedStudyHours == 1.0 ? "1 hora" : "$_selectedStudyHours horas"}.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    int minutes = (_remainingTimeInSeconds % 3600) ~/ 60;
    int seconds = _remainingTimeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = _isBreakTime ? Colors.green : theme.primaryColor;
    final modeText = _isBreakTime ? 'Pausa' : 'Foco';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro de Estudo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Seletor de Tempo de Estudo
                Text(
                  'Tempo Total de Estudo:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: _selectedStudyHours,
                      icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
                      items: _studyOptions.map<DropdownMenuItem<double>>((hours) {
                        int cycles = (hours * 2).toInt();
                        String label = hours == 1.0 
                            ? '1 Hora' 
                            : '${hours.toString().replaceAll(RegExp(r'\.0$'), '')} Horas';
                        return DropdownMenuItem<double>(
                          value: hours,
                          child: Text('$label ($cycles Pomodoros)'),
                        );
                      }).toList(),
                      onChanged: _isRunning 
                          ? null 
                          : (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedStudyHours = val;
                                  _setupCycles();
                                });
                              }
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Status do Ciclo Atual
                Text(
                  '$modeText - Ciclo $_currentCycle de $_totalCycles',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Círculo do Pomodoro com FittedBox para evitar Overflow
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activeColor,
                      width: 12.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          _formattedTime,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 80, // Tamanho grande, mas o FittedBox vai reduzir se necessário
                            color: activeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Botões de Controle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRunning)
                      ElevatedButton.icon(
                        onPressed: _startTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_isBreakTime ? 'Iniciar Pausa' : 'Iniciar Foco'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _stopTimer,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pausar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
