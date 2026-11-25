// lib/core/network/google_calendar_client.dart

import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

import 'google_calendar_exceptions.dart';

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
      try {
        await _googleSignIn.initialize();
        _initialized = true;
      } on UnsupportedError catch (e) {
        throw CalendarAuthException(
          type: CalendarAuthErrorType.platformUnsupported,
          message:
              'Google Sign-In no está soportado o configurado en esta plataforma.',
          cause: e,
        );
      } catch (e) {
        throw _mapError(e);
      }
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      _currentUser = account;
      return account;
    } on CalendarAuthException {
      rethrow;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<calendar.CalendarApi> _getCalendarApi() async {
    try {
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
        throw const CalendarAuthException(
          type: CalendarAuthErrorType.canceled,
          message: 'No se completó el inicio de sesión con Google.',
        );
      }

      final authz = await account.authorizationClient.authorizeScopes(_scopes);
      final httpClient = authz.authClient(scopes: _scopes);

      return calendar.CalendarApi(httpClient);
    } on CalendarAuthException {
      rethrow;
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Obtiene la lista de eventos en un rango de tiempo específico (getEventsInRange)
  Future<List<calendar.Event>> getEventsInRange(
      DateTime start, DateTime end) async {
    try {
      final api = await _getCalendarApi();
      final events = await api.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } on CalendarAuthException {
      rethrow;
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// Crea el bloque de tiempo de enfoque en el calendario
  Future<String> createFocusTimeBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String description,
  }) async {
    try {
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
    } on CalendarAuthException {
      rethrow;
    } catch (e) {
      throw _mapError(e);
    }
  }

  CalendarAuthException _mapError(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return CalendarAuthException(
            type: CalendarAuthErrorType.canceled,
            message: 'Inicio de sesión cancelado por el usuario.',
            cause: error,
          );
        case GoogleSignInExceptionCode.interrupted:
          return CalendarAuthException(
            type: CalendarAuthErrorType.interrupted,
            message:
                'La autenticación con Google fue interrumpida. Intenta de nuevo.',
            cause: error,
          );
        case GoogleSignInExceptionCode.uiUnavailable:
          return CalendarAuthException(
            type: CalendarAuthErrorType.uiUnavailable,
            message:
                'No hay una interfaz disponible para iniciar sesión en este dispositivo.',
            cause: error,
          );
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          return CalendarAuthException(
            type: CalendarAuthErrorType.configurationError,
            message:
                'Falta configuración OAuth2 válida para Google Sign-In en esta plataforma.',
            cause: error,
          );
        default:
          return CalendarAuthException(
            type: CalendarAuthErrorType.unknown,
            message: error.description ??
                'Error inesperado al autenticar con Google.',
            cause: error,
          );
      }
    }

    if (error is UnsupportedError) {
      return CalendarAuthException(
        type: CalendarAuthErrorType.platformUnsupported,
        message:
            'Google Sign-In no está soportado o configurado en esta plataforma.',
        cause: error,
      );
    }

    if (error is SocketException || error is http.ClientException) {
      return CalendarAuthException(
        type: CalendarAuthErrorType.networkError,
        message:
            'Sin conexión a internet o error de red al conectar con Google Calendar.',
        cause: error,
      );
    }

    if (error is calendar.DetailedApiRequestError) {
      if (error.status == 401 || error.status == 403) {
        return CalendarAuthException(
          type: CalendarAuthErrorType.insufficientPermissions,
          message:
              'Permisos insuficientes o sesión expirada en Google Calendar. Vuelve a iniciar sesión.',
          cause: error,
        );
      }
      return CalendarAuthException(
        type: CalendarAuthErrorType.unknown,
        message:
            'Google Calendar respondió con error (${error.status}): ${error.message ?? 'intenta más tarde'}.',
        cause: error,
      );
    }

    return CalendarAuthException(
      type: CalendarAuthErrorType.unknown,
      message: 'No se pudo completar la operación con Google Calendar: $error',
      cause: error,
    );
  }
}
