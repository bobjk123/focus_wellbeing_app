// lib/features/calendar_sync/data/repositories/calendar_sync_repository_impl.dart

import 'package:focus_wellbeing_app/features/calendar_sync/data/repositories/calendar_sync_repository.dart';

import '../../domain/entities/focus_schedule_proposal.dart';
import '../../domain/entities/time_slot.dart';
import '../datasources/calendar_sync_remote_datasource.dart';

class CalendarSyncRepositoryImpl implements CalendarSyncRepository {
  final CalendarSyncRemoteDataSource remoteDataSource;

  CalendarSyncRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FocusScheduleProposal> calculateOptimalFocusSlot({
    required String taskId,
    required String taskTitle,
    required int durationMinutes,
    required DateTime preferredStart,
  }) async {
    final searchEnd = preferredStart.add(const Duration(hours: 8));
    final busySlots = await remoteDataSource.getBusySlots(
      startTime: preferredStart,
      endTime: searchEnd,
    );

    DateTime candidateStart = preferredStart;
    DateTime candidateEnd =
        candidateStart.add(Duration(minutes: durationMinutes));
    bool conflictDetected = false;

    // Algoritmo de detección de solapamiento y búsqueda de ventana libre
    for (var busy in busySlots) {
      // Si la ventana propuesta se solapa con un evento existente
      if (candidateStart.isBefore(busy.end) &&
          candidateEnd.isAfter(busy.start)) {
        conflictDetected = true;
        // Mover la propuesta al final del evento en conflicto con un margen de 5 min
        candidateStart = busy.end.add(const Duration(minutes: 5));
        candidateEnd = candidateStart.add(Duration(minutes: durationMinutes));
      }
    }

    String reasoning = conflictDetected
        ? 'Explicación IA: La hora preferida solapaba con un compromiso en tu agenda. '
            'Se desplazó el bloque al primer espacio libre sin interrupciones.'
        : 'Explicación IA: El horario seleccionado se encuentra completamente libre en tu Google Calendar.';

    return FocusScheduleProposal(
      taskId: taskId,
      taskTitle: taskTitle,
      proposedStart: candidateStart,
      proposedEnd: candidateEnd,
      xaiReasoning: reasoning,
      hasConflict: conflictDetected,
    );
  }

  @override
  Future<String> confirmAndScheduleBlock(FocusScheduleProposal proposal) async {
    return await remoteDataSource.insertEvent(
      title: 'Focus: ${proposal.taskTitle}',
      start: proposal.proposedStart,
      end: proposal.proposedEnd,
      description: 'Bloque de enfoque auto-agendado. ${proposal.xaiReasoning}',
    );
  }
}
