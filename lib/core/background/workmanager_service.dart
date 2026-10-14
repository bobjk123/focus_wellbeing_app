// lib/core/background/workmanager_service.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'background_worker.dart';

class WorkmanagerService {
  /// Determina si la plataforma actual cuenta con soporte nativo de Workmanager.
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux;
  }

  static Future<void> initialize() async {
    if (!isSupported) {
      debugPrint(
        'Workmanager no está implementado en la plataforma actual (${Platform.operatingSystem}). Omitiendo inicialización.',
      );
      return;
    }

    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  /// Registra la tarea periódica de revisión de tiempo de pantalla
  static Future<void> registerPeriodicScreenTimeCheck() async {
    if (!isSupported) {
      debugPrint(
        'Workmanager no está implementado en la plataforma actual (${Platform.operatingSystem}). Omitiendo tarea periódica.',
      );
      return;
    }

    await Workmanager().registerPeriodicTask(
      'periodic_screen_time_check_id',
      screenTimeCheckTask,
      frequency: const Duration(minutes: 15), // Intervalo mínimo nativo (15m)
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
