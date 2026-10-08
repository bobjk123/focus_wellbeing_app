// lib/features/focus_pomodoro/presentation/pages/pomodoro_timer_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/pomodoro_bloc.dart';
import '../bloc/pomodoro_event.dart';
import '../bloc/pomodoro_state.dart';

class PomodoroTimerPage extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const PomodoroTimerPage({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  // Configuración de la sesión Pomodoro
  static const int _totalSessionMinutes = 25;
  int _secondsRemaining = _totalSessionMinutes * 60;
  Timer? _timer;
  bool _isRunning = false;

  // Estado del árbol virtual y fatiga
  String _selectedTreeSpecies = 'Roble Nobilis';
  int _fatigueRating = 2; // Nivel por defecto: 2 (Normal)

  final List<String> _treeSpeciesList = [
    'Roble Nobilis',
    'Pino Silvestre',
    'Bonsai Zen'
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _onPomodoroFinished();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _totalSessionMinutes * 60;
    });
  }

  void _onPomodoroFinished() {
    // Disparar el evento al BLoC al completar el tiempo
    context.read<PomodoroBloc>().add(
          FinishPomodoroSessionEvent(
            taskId: widget.taskId,
            taskTitle: widget.taskTitle,
            durationMinutes: _totalSessionMinutes,
            fatigueRating: _fatigueRating,
            treeSpecies: _selectedTreeSpecies,
          ),
        );
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress =>
      1.0 - (_secondsRemaining / (_totalSessionMinutes * 60));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sesión de Enfoque - ${widget.taskTitle}'),
        centerTitle: true,
      ),
      body: BlocConsumer<PomodoroBloc, PomodoroState>(
        listener: (context, state) {
          if (state is PomodoroCompletedState) {
            _showCompletionDialog(context, state);
          } else if (state is PomodoroErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PomodoroSyncingState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                      'Sincronizando con Google Calendar y sembrando tu árbol...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Selector de Árbol Virtual (Forest)
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.park, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Especie a plantar:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _selectedTreeSpecies,
                          underline: const SizedBox(),
                          items: _treeSpeciesList.map((species) {
                            return DropdownMenuItem(
                                value: species, child: Text(species));
                          }).toList(),
                          onChanged: _isRunning
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(
                                        () => _selectedTreeSpecies = value);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Temporizador Circular
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 12,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formattedTime,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRunning ? 'EN CONCENTRACIÓN' : 'EN PAUSA',
                            style: theme.textTheme.labelMedium?.copyWith(
                              letterSpacing: 1.5,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 3. Evaluación de Fatiga Cognitiva (Higiene Cognitiva / IA)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Nivel de fatiga percibida (1 a 5):',
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _fatigueRating.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: 'Nivel $_fatigueRating',
                          onChanged: (value) {
                            setState(() => _fatigueRating = value.toInt());
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 (Energizado)',
                                style: theme.textTheme.bodySmall),
                            Text('5 (Agotado)',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Controles del Temporizador
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                    ),
                    const SizedBox(width: 24),
                    FloatingActionButton.large(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 24),
                    IconButton.filledTonal(
                      iconSize: 32,
                      onPressed: _onPomodoroFinished,
                      icon: const Icon(Icons.check),
                      tooltip: 'Forzar finalización',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Modal de retroalimentación con sugerencias de la IA Ética (XAI)
  void _showCompletionDialog(
      BuildContext context, PomodoroCompletedState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('¡Sesión Completada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.park, color: Colors.green),
              title: const Text('Gamificación Forest'),
              subtitle: Text(state.treePlantedMessage),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Google Calendar'),
              subtitle: Text(state.calendarSyncMessage),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.purple),
              title: const Text('Asistente IA - Higiene Cognitiva'),
              subtitle: Text(state.aiRestRecommendation),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resetTimer();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
