// lib/features/focus_pomodoro/domain/repositories/pomodoro_repository.dart

import '../../../shared/data/models/app_entities.dart';

abstract class PomodoroRepository {
  Future<DailyForestStats> getDailyForestStats();

  Future<void> saveCompletedSession({
    required PomodoroSession session,
    required String treeSpecies,
    required String taskTitle,
  });
}
