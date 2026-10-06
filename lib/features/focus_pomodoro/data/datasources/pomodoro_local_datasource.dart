// lib/features/focus_pomodoro/data/datasources/pomodoro_local_datasource.dart

import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:isar/isar.dart';

abstract class PomodoroLocalDataSource {
  Future<void> saveSessionAndPlantTree({
    required PomodoroSession session,
    required PlantTree tree,
  });
}

class PomodoroLocalDataSourceImpl implements PomodoroLocalDataSource {
  final Isar isar;

  PomodoroLocalDataSourceImpl(this.isar);

  @override
  Future<void> saveSessionAndPlantTree({
    required PomodoroSession session,
    required PlantTree tree,
  }) async {
    // Transacción atómica en Isar DB cifrada
    await isar.writeTxn(() async {
      await isar.pomodoroSessions.put(session);
      await isar.plantTrees.put(tree);
    });
  }
}
