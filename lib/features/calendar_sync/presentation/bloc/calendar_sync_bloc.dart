// lib/features/calendar_sync/presentation/bloc/calendar_sync_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/data/repositories/calendar_sync_repository.dart';
import 'calendar_sync_event.dart';
import 'calendar_sync_state.dart';

class CalendarSyncBloc extends Bloc<CalendarSyncEvent, CalendarSyncState> {
  final CalendarSyncRepository repository;

  CalendarSyncBloc({required this.repository})
      : super(CalendarSyncInitialState()) {
    on<RequestFocusBlockScheduleEvent>(_onRequestSchedule);
    on<ConfirmScheduleProposalEvent>(_onConfirmSchedule);
  }

  Future<void> _onRequestSchedule(
    RequestFocusBlockScheduleEvent event,
    Emitter<CalendarSyncState> emit,
  ) async {
    emit(CalendarSyncLoadingState());
    try {
      final proposal = await repository.calculateOptimalFocusSlot(
        taskId: event.taskId,
        taskTitle: event.taskTitle,
        durationMinutes: event.durationMinutes,
        preferredStart: event.preferredStart,
      );
      emit(ProposalGeneratedState(proposal));
    } catch (e) {
      emit(CalendarSyncErrorState('Error al evaluar disponibilidad: $e'));
    }
  }

  Future<void> _onConfirmSchedule(
    ConfirmScheduleProposalEvent event,
    Emitter<CalendarSyncState> emit,
  ) async {
    emit(CalendarSyncLoadingState());
    try {
      final eventId = await repository.confirmAndScheduleBlock(event.proposal);
      emit(ScheduleConfirmedState(
        googleEventId: eventId,
        message: 'Bloque de tiempo agendado exitosamente en Google Calendar.',
      ));
    } catch (e) {
      emit(CalendarSyncErrorState(
          'Error al crear el evento en el calendario: $e'));
    }
  }
}
