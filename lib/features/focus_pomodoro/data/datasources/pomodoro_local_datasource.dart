// lib/features/focus_pomodoro/data/datasources/pomodoro_local_datasource.dart

import 'package:focus_wellbeing_app/core/database/sqlite_database.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

abstract class PomodoroLocalDataSource {
  Future<DailyForestStats> getDailyForestStats();

  Future<void> saveSessionAndPlantTree({
    required PomodoroSession session,
    required PlantTree tree,
  });
}

class PomodoroLocalDataSourceImpl implements PomodoroLocalDataSource {
  final SqliteDatabase database;

  PomodoroLocalDataSourceImpl(this.database);

  @override
  Future<DailyForestStats> getDailyForestStats() =>
      database.getDailyForestStats();

  @override
  Future<void> saveSessionAndPlantTree({
    required PomodoroSession session,
    required PlantTree tree,
  }) async {
    await database.saveSessionAndPlantTree(session: session, tree: tree);
  }
}
