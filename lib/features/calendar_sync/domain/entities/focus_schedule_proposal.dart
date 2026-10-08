// lib/features/calendar_sync/domain/entities/focus_schedule_proposal.dart

class FocusScheduleProposal {
  final String taskId;
  final String taskTitle;
  final DateTime proposedStart;
  final DateTime proposedEnd;
  final String xaiReasoning; // Justificación clara de la IA (XAI)
  final bool hasConflict;

  FocusScheduleProposal({
    required this.taskId,
    required this.taskTitle,
    required this.proposedStart,
    required this.proposedEnd,
    required this.xaiReasoning,
    required this.hasConflict,
  });
}
