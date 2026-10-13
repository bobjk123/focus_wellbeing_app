// lib/core/background/background_worker.dart

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../database/sqlite_database.dart';
import '../notifications/notification_service.dart';

const String screenTimeCheckTask = 'com.wellbeing.screenTimeCheckTask';

/// Punto de entrada del aisllado (Isolate) de Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    switch (task) {
      case screenTimeCheckTask:
        await _checkScreenTimeLimitsInBackground();
        break;
    }

    return Future.value(true);
  });
}

/// Lógica de verificación en segundo plano conectada a SQLite cifrado.
Future<void> _checkScreenTimeLimitsInBackground() async {
  try {
    // 1. Inicializar el servicio de notificaciones locales
    final notificationService = NotificationService();
    await notificationService.initialize();

    // 2. Abrir la misma base cifrada en el isolate en segundo plano.
    final database = await SqliteDatabase.open();

    // 3. Consultar las aplicaciones configuradas con límites
    final usageLimits = await database.getUsageLimits();

    for (var limit in usageLimits) {
      final isExceeded = limit.dailyLimitMinutes > 0 &&
          limit.currentUsageMinutes >= limit.dailyLimitMinutes;

      // Disparar la notificación si excede y no ha sido notificado hoy
      if (isExceeded && !limit.isBlocked) {
        await notificationService.showAppLimitExceededNotification(
          notificationId: limit.id,
          appName: limit.appName,
          limitMinutes: limit.dailyLimitMinutes,
        );

        limit.isBlocked = true;
        await database.saveUsageLimit(limit);
      }
    }

    await database.close();
  } catch (e) {
    debugPrint('Error en el worker en segundo plano: $e');
  }
}
