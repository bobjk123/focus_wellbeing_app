// lib/core/network/google_calendar_client.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleCalendarClient {
  static const List<String> _scopes = [
    calendar.CalendarApi.calendarEventsScope,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      throw Exception('Error al autenticar con Google: $e');
    }
  }

  Future<calendar.CalendarApi> _getCalendarApi() async {
    var account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    account ??= await signIn();

    if (account == null) {
      throw Exception('Usuario no autenticado en Google.');
    }

    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      throw Exception('No se pudieron obtener credenciales OAuth2.');
    }

    return calendar.CalendarApi(httpClient);
  }

  /// Obtiene la lista de eventos en un rango de tiempo específico (getEventsInRange)
  Future<List<calendar.Event>> getEventsInRange(
      DateTime start, DateTime end) async {
    final api = await _getCalendarApi();
    final events = await api.events.list(
      'primary',
      timeMin: start.toUtc(),
      timeMax: end.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );
    return events.items ?? [];
  }

  /// Crea el bloque de tiempo de enfoque en el calendario
  Future<String> createFocusTimeBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  }) async {
    final api = await _getCalendarApi();

    final event = calendar.Event()
      ..summary = title
      ..description = description
      ..start = calendar.EventDateTime(
        dateTime: startTime.toUtc(),
        timeZone: 'UTC',
      )
      ..end = calendar.EventDateTime(
        dateTime: endTime.toUtc(),
        timeZone: 'UTC',
      )
      ..colorId = '10';

    final createdEvent = await api.events.insert(event, 'primary');
    return createdEvent.id ?? '';
  }
}
