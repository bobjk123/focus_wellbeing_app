/// Categorías de error para autenticación OAuth2 y operaciones de Google Calendar.
enum CalendarAuthErrorType {
  canceled,
  interrupted,
  uiUnavailable,
  configurationError,
  platformUnsupported,
  insufficientPermissions,
  networkError,
  unknown,
}

/// Excepción tipada con mensajes accionables para errores de Google Sign-In y Calendar.
class CalendarAuthException implements Exception {
  final CalendarAuthErrorType type;
  final String message;
  final Object? cause;

  const CalendarAuthException({
    required this.type,
    required this.message,
    this.cause,
  });

  @override
  String toString() => message;
}
