import 'package:flutter/services.dart';

/// Estadística cruda de uso obtenida directamente del sistema operativo.
class SystemAppUsage {
  final String packageName;
  final String appName;
  final int usageMinutes;

  const SystemAppUsage({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });

  factory SystemAppUsage.fromMap(Map<Object?, Object?> map) {
    return SystemAppUsage(
      packageName: (map['packageName'] as String?) ?? '',
      appName: (map['appName'] as String?) ?? 'App desconocida',
      usageMinutes: (map['usageMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Puente multiplataforma hacia las APIs nativas de tiempo de pantalla
/// (`UsageStatsManager` en Android y ventana activa Win32 en Windows).
class SystemUsageStatsService {
  static const MethodChannel _defaultChannel =
      MethodChannel('com.wellbeing.focus_wellbeing_app/usage_stats');

  final MethodChannel _channel;

  SystemUsageStatsService({MethodChannel? channel})
      : _channel = channel ?? _defaultChannel;

  Future<bool> hasUsagePermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasUsagePermission');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod<void>('openUsageAccessSettings');
    } on MissingPluginException {
      // Plataforma sin ajustes de uso del sistema.
    } on PlatformException {
      // Ignorar si no está disponible en el dispositivo actual.
    }
  }

  Future<List<SystemAppUsage>> getTodayUsageStats() async {
    try {
      final rawList =
          await _channel.invokeMethod<List<Object?>>('getTodayUsageStats');
      if (rawList == null) return const [];
      return rawList
          .whereType<Map<Object?, Object?>>()
          .map(SystemAppUsage.fromMap)
          .where((item) => item.packageName.isNotEmpty)
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }
}
