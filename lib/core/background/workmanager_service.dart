// lib/core/background/workmanager_service.dart

import 'package:workmanager/workmanager.dart';
import 'background_worker.dart';

class WorkmanagerService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Cambiar a true para ver logs en la consola
    );
  }

  /// Registra la tarea periódica de revisión de tiempo de pantalla
  static Future<void> registerPeriodicScreenTimeCheck() async {
    await Workmanager().registerPeriodicTask(
      'periodic_screen_time_check_id',
      screenTimeCheckTask,
      frequency: const Duration(minutes: 15), // Intervalo mínimo nativo (15m)
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}
