// lib/core/network/google_calendar_client.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleCalendarClient {
  // Scope estricto con el principio de mínimos privilegios (solo eventos)
  static const List<String> _scopes = [
    calendar.CalendarApi.calendarEventsScope,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);

  /// Inicia sesión con Google respetando el scope de mínimos privilegios
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      throw Exception('Error al autenticar con Google: $e');
    }
  }

  /// Cierra la sesión activa
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Obtiene un cliente autenticado de la API de Google Calendar
  Future<calendar.CalendarApi> _getCalendarApi() async {
    var account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    account ??= await signIn();

    if (account == null) {
      throw Exception('Usuario no autenticado en Google.');
    }

    // Extensión que convierte las credenciales de GoogleSignIn a un cliente HTTP autenticado para googleapis
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      throw Exception(
          'No se pudieron obtener los encabezados de autenticación OAuth2.');
    }

    return calendar.CalendarApi(httpClient);
  }

  /// Crea un bloque de tiempo de enfoque en el calendario principal ('primary')
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
      ..colorId =
          '10' // Color verde para indicar bloque de enfoque / productividad
      ..transparency = 'opaque'; // Marca la disponibilidad como 'Ocupado'

    final createdEvent = await api.events.insert(event, 'primary');
    return createdEvent.id ?? '';
  }
}
