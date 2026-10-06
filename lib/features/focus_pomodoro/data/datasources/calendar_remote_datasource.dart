// lib/features/focus_pomodoro/data/datasources/calendar_remote_datasource.dart

abstract class CalendarRemoteDataSource {
  Future<String> createTimeBlockEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  });
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  // Aquí se integraría la llamada directa con el paquete googleapis (Google Calendar REST API)
  @override
  Future<String> createTimeBlockEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  }) async {
    // Simulación de respuesta exitosa desde la API de Google
    await Future.delayed(const Duration(milliseconds: 800));
    return 'gcal_event_${DateTime.now().millisecondsSinceEpoch}';
  }
}
