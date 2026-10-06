// lib/features/focus_pomodoro/domain/usecases/complete_pomodoro_session_usecase.dart

import '../repositories/pomodoro_repository.dart';
import '../../../shared/data/models/app_entities.dart';

class CompletePomodoroSessionParams {
  final String taskId;
  final String taskTitle;
  final int durationMinutes;
  final int fatigueRating;
  final String treeSpecies;

  CompletePomodoroSessionParams({
    required this.taskId,
    required this.taskTitle,
    required this.durationMinutes,
    required this.fatigueRating,
    required this.treeSpecies,
  });
}

class CompletePomodoroSessionUseCase {
  final PomodoroRepository repository;

  CompletePomodoroSessionUseCase(this.repository);

  Future<void> call(CompletePomodoroSessionParams params) async {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(minutes: params.durationMinutes));

    final session = PomodoroSession()
      ..uuid = DateTime.now().millisecondsSinceEpoch.toString()
      ..taskId = params.taskId
      ..durationMinutes = params.durationMinutes
      ..startTime = startTime
      ..endTime = now
      ..isSuccessful = true
      ..fatigueRating = params.fatigueRating
      ..calendarSyncStatus = SyncStatus.pending;

    await repository.saveCompletedSession(
      session: session,
      treeSpecies: params.treeSpecies,
      taskTitle: params.taskTitle,
    );
  }
}
