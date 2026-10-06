// lib/features/focus_pomodoro/presentation/bloc/pomodoro_event.dart

abstract class PomodoroEvent {}

class FinishPomodoroSessionEvent extends PomodoroEvent {
  final String taskId;
  final String taskTitle;
  final int durationMinutes;
  final int fatigueRating;
  final String treeSpecies;

  FinishPomodoroSessionEvent({
    required this.taskId,
    required this.taskTitle,
    required this.durationMinutes,
    required this.fatigueRating,
    required this.treeSpecies,
  });
}
