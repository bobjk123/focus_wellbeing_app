// lib/features/calendar_sync/domain/repositories/calendar_sync_repository.dart

import 'package:focus_wellbeing_app/features/calendar_sync/domain/entities/focus_schedule_proposal.dart';

abstract class CalendarSyncRepository {
  Future<FocusScheduleProposal> calculateOptimalFocusSlot({
    required String taskId,
    required String taskTitle,
    required int durationMinutes,
    required DateTime preferredStart,
  });

  Future<String> confirmAndScheduleBlock(FocusScheduleProposal proposal);
}
