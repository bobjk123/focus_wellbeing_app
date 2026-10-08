// lib/features/calendar_sync/presentation/bloc/calendar_sync_event.dart

import '../../domain/entities/focus_schedule_proposal.dart';

abstract class CalendarSyncEvent {}

class RequestFocusBlockScheduleEvent extends CalendarSyncEvent {
  final String taskId;
  final String taskTitle;
  final int durationMinutes;
  final DateTime preferredStart;

  RequestFocusBlockScheduleEvent({
    required this.taskId,
    required this.taskTitle,
    required this.durationMinutes,
    required this.preferredStart,
  });
}

class ConfirmScheduleProposalEvent extends CalendarSyncEvent {
  final FocusScheduleProposal proposal;

  ConfirmScheduleProposalEvent(this.proposal);
}
