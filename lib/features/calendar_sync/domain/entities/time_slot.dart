// lib/features/calendar_sync/domain/entities/time_slot.dart

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isBusy;
  final String? eventSummary;

  TimeSlot({
    required this.start,
    required this.end,
    required this.isBusy,
    this.eventSummary,
  });

  Duration get duration => end.difference(start);
}
