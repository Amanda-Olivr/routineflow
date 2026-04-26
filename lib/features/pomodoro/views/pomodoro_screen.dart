import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
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

  // Animação do círculo de progresso
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _setupCycles();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupCycles() {
    _totalCycles = (_selectedStudyHours * 2).toInt();
    _currentCycle = 1;
    _isBreakTime = false;
    _remainingTimeInSeconds = _focusTimeInSeconds;
    _isRunning = false;
    _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (_remainingTimeInSeconds > 0) {
      setState(() => _remainingTimeInSeconds--);
    } else {
      if (!_isBreakTime) {
        if (_currentCycle >= _totalCycles) {
          _stopTimer();
          _showCompletionDialog();
        } else {
          setState(() {
            _isBreakTime = true;
            _remainingTimeInSeconds = _breakTimeInSeconds;
          });
        }
      } else {
        setState(() {
          _isBreakTime = false;
          _currentCycle++;
          _remainingTimeInSeconds = _focusTimeInSeconds;
        });
      }
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _setupCycles());
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Parabéns! 🎉', textAlign: TextAlign.center),
        content: Text(
          'Você concluiu sua meta de ${_selectedStudyHours == 1.0 ? "1 hora" : "$_selectedStudyHours horas"} de estudo focado!',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetTimer();
              },
              child: const Text('Nova sessão'),
            ),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    final m = (_remainingTimeInSeconds % 3600) ~/ 60;
    final s = _remainingTimeInSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _cycleProgress {
    final total = _isBreakTime ? _breakTimeInSeconds : _focusTimeInSeconds;
    return 1 - (_remainingTimeInSeconds / total);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores de estado: índigo (foco) / teal (pausa)
    final focusColor  = theme.primaryColor;
    final breakColor  = theme.colorScheme.secondary;
    final activeColor = _isBreakTime ? breakColor : focusColor;
    final bgGlow      = activeColor.withOpacity(isDark ? 0.15 : 0.08);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pomodoro de Estudo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // ── Seletor de Duração ───────────────────────────────────────
            _buildDurationSelector(theme),
            const SizedBox(height: 32),

            // ── Indicador de Ciclo ───────────────────────────────────────
            _buildCycleIndicator(theme, activeColor),
            const SizedBox(height: 28),

            // ── Timer Ring ───────────────────────────────────────────────
            _buildTimerRing(theme, activeColor, bgGlow),
            const SizedBox(height: 36),

            // ── Botões de Controle ───────────────────────────────────────
            _buildControls(theme, activeColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_filled_rounded, color: theme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text('Meta de Estudo', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                value: _selectedStudyHours,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
                dropdownColor: theme.colorScheme.surface,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                items: _studyOptions.map<DropdownMenuItem<double>>((h) {
                  final cycles = (h * 2).toInt();
                  final label = h == 1.0
                      ? '1 Hora'
                      : '${h.toString().replaceAll(RegExp(r'\.0$'), '')} Horas';
                  return DropdownMenuItem<double>(
                    value: h,
                    child: Text('$label — $cycles Pomodoros'),
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
        ],
      ),
    );
  }

  Widget _buildCycleIndicator(ThemeData theme, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: activeColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isBreakTime ? Icons.coffee_rounded : Icons.psychology_rounded,
                color: activeColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _isBreakTime
                    ? 'Pausa  •  Ciclo $_currentCycle de $_totalCycles'
                    : 'Foco  •  Ciclo $_currentCycle de $_totalCycles',
                style: theme.textTheme.labelLarge?.copyWith(color: activeColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerRing(ThemeData theme, Color activeColor, Color bgGlow) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) {
        final scale = _isRunning ? _pulseAnim.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow de fundo
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgGlow,
              ),
            ),
            // Anel de progresso (custom painted)
            SizedBox(
              width: 240,
              height: 240,
              child: CircularProgressIndicator(
                value: _cycleProgress,
                strokeWidth: 10,
                backgroundColor: activeColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            // Tempo
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formattedTime,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                    letterSpacing: -1,
                    fontSize: 56,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isBreakTime ? 'Respire...' : 'Mantenha o foco',
                  style: theme.textTheme.bodySmall?.copyWith(color: activeColor.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ThemeData theme, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão Reiniciar
        _ControlButton(
          icon: Icons.refresh_rounded,
          label: 'Reiniciar',
          onTap: _resetTimer,
          color: theme.colorScheme.error,
          outlined: true,
          theme: theme,
        ),
        const SizedBox(width: 16),
        // Botão principal Play / Pause
        _ControlButton(
          icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          label: _isRunning
              ? 'Pausar'
              : _isBreakTime
                  ? 'Iniciar Pausa'
                  : 'Iniciar Foco',
          onTap: _isRunning ? _stopTimer : _startTimer,
          color: activeColor,
          outlined: false,
          theme: theme,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool outlined;
  final ThemeData theme;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.outlined,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: theme.textTheme.labelLarge,
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: theme.textTheme.labelLarge,
      ),
    );
  }
}
