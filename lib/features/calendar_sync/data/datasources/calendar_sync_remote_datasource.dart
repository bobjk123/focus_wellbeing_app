// lib/features/calendar_sync/data/datasources/calendar_sync_remote_datasource.dart

import 'package:googleapis/calendar/v3.dart' as calendar;
import '../../../../core/network/google_calendar_client.dart';
import '../../domain/entities/time_slot.dart';

abstract class CalendarSyncRemoteDataSource {
  Future<List<TimeSlot>> getBusySlots({
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<String> insertEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    required String description,
  });
}

class CalendarSyncRemoteDataSourceImpl implements CalendarSyncRemoteDataSource {
  final GoogleCalendarClient calendarClient;

  CalendarSyncRemoteDataSourceImpl(this.calendarClient);

  @override
  Future<List<TimeSlot>> getBusySlots({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Consulta a la API de Google Calendar usando los eventos de la agenda principal ('primary')
    final events = await calendarClient.getEventsInRange(startTime, endTime);

    return events.map((e) {
      final start = e.start?.dateTime ?? e.start?.date ?? startTime;
      final end = e.end?.dateTime ?? e.end?.date ?? endTime;

      return TimeSlot(
        start: start.toLocal(),
        end: end.toLocal(),
        isBusy: true,
        eventSummary: e.summary,
      );
    }).toList();
  }

  @override
  Future<String> insertEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    required String description,
  }) async {
    return await calendarClient.createFocusTimeBlock(
      title: title,
      startTime: start,
      endTime: end,
      description: description,
    );
  }
}
