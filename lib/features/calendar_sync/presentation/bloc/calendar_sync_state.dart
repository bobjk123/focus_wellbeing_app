// lib/features/calendar_sync/presentation/bloc/calendar_sync_state.dart

import '../../domain/entities/focus_schedule_proposal.dart';

abstract class CalendarSyncState {}

class CalendarSyncInitialState extends CalendarSyncState {}

class CalendarSyncLoadingState extends CalendarSyncState {}

class ProposalGeneratedState extends CalendarSyncState {
  final FocusScheduleProposal proposal;

  ProposalGeneratedState(this.proposal);
}

class ScheduleConfirmedState extends CalendarSyncState {
  final String googleEventId;
  final String message;

  ScheduleConfirmedState({
    required this.googleEventId,
    required this.message,
  });
}

class CalendarSyncErrorState extends CalendarSyncState {
  final String message;

  CalendarSyncErrorState(this.message);
}
