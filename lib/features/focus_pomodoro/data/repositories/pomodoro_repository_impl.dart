// lib/features/focus_pomodoro/data/repositories/pomodoro_repository_impl.dart

import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/pomodoro_local_datasource.dart';
import '../datasources/calendar_remote_datasource.dart';


class PomodoroRepositoryImpl implements PomodoroRepository {
  final PomodoroLocalDataSource localDataSource;
  final CalendarRemoteDataSource remoteDataSource;

  PomodoroRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> saveCompletedSession({
    required PomodoroSession session,
    required String treeSpecies,
    required String taskTitle,
  }) async {
    // 1. Crear el registro del árbol virtual (Forest)
    final tree = PlantTree()
      ..uuid = DateTime.now().millisecondsSinceEpoch.toString()
      ..species = treeSpecies
      ..status = TreeStatus.completed
      ..plantedAt = session.endTime ?? DateTime.now()
      ..growthDurationMinutes = session.durationMinutes
      ..associatedPomodoroSessionId = session.uuid;

    // 2. Guardar sesión y árbol localmente en Isar DB
    await localDataSource.saveSessionAndPlantTree(
      session: session,
      tree: tree,
    );

    // 3. Sincronizar evento en Google Calendar
    try {
      final googleEventId = await remoteDataSource.createTimeBlockEvent(
        title: 'Focus: $taskTitle',
        startTime: session.startTime,
        endTime: session.endTime ?? DateTime.now(),
        description:
            'Bloque de enfoque registrado por App de Bienestar Digital.',
      );

      session.calendarSyncStatus = SyncStatus.synced;
    } catch (_) {
      session.calendarSyncStatus = SyncStatus.error;
    }
  }
}
