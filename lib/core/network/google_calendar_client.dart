// lib/core/network/google_calendar_client.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleCalendarClient {
  static const List<String> _scopes = [
    calendar.CalendarApi.calendarEventsScope,
  ];

  static bool _initialized = false;
  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  GoogleCalendarClient({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      _currentUser = account;
      return account;
    } catch (e) {
      throw Exception('Error al autenticar con Google: $e');
    }
  }

  Future<calendar.CalendarApi> _getCalendarApi() async {
    await _ensureInitialized();
    var account = _currentUser;
    if (account == null) {
      final attempt = _googleSignIn.attemptLightweightAuthentication();
      if (attempt != null) {
        account = await attempt;
        _currentUser = account;
      }
    }
    account ??= await signIn();

    if (account == null) {
      throw Exception('Usuario no autenticado en Google.');
    }

    final authz = await account.authorizationClient.authorizeScopes(_scopes);
    final httpClient = authz.authClient(scopes: _scopes);

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
