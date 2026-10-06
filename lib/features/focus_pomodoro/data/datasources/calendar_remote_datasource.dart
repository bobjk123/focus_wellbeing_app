// lib/features/focus_pomodoro/data/datasources/calendar_remote_datasource.dart

import '../../../../core/network/google_calendar_client.dart';

abstract class CalendarRemoteDataSource {
  Future<String> createTimeBlockEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  });
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final GoogleCalendarClient calendarClient;

  CalendarRemoteDataSourceImpl(this.calendarClient);

  @override
  Future<String> createTimeBlockEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  }) async {
    return await calendarClient.createFocusTimeBlock(
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: description,
    );
  }
}
