// lib/features/focus_pomodoro/presentation/bloc/pomodoro_state.dart

abstract class PomodoroState {}

class DailyForestStatsLoadedState extends PomodoroState {
  final int treesPlanted;
  final int focusMinutes;

  DailyForestStatsLoadedState({
    required this.treesPlanted,
    required this.focusMinutes,
  });
}

class PomodoroInitialState extends PomodoroState {}

class PomodoroRunningState extends PomodoroState {}

class PomodoroSyncingState extends PomodoroState {}

class PomodoroCompletedState extends PomodoroState {
  final String treePlantedMessage;
  final String calendarSyncMessage;
  final String aiRestRecommendation;

  PomodoroCompletedState({
    required this.treePlantedMessage,
    required this.calendarSyncMessage,
    required this.aiRestRecommendation,
  });
}

class PomodoroErrorState extends PomodoroState {
  final String message;
  PomodoroErrorState(this.message);
}
