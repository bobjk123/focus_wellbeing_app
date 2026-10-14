// lib/core/notifications/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el plugin de notificaciones para Android, iOS y Desktop
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open app');

    const WindowsInitializationSettings windowsSettings =
        WindowsInitializationSettings(
      appName: 'Focus & Wellbeing App',
      appUserModelId: 'com.wellbeing.focus_wellbeing_app',
      guid: 'd28a3f78-2cfb-4a55-83c7-4dc567843e91',
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _notificationsPlugin.initialize(settings: settings);
  }

  /// Solicita permisos de notificación en Android 13+ e iOS
  Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Envía una alerta cuando una aplicación excede su límite de uso diario
  Future<void> showAppLimitExceededNotification({
    required int notificationId,
    required String appName,
    required int limitMinutes,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'wellbeing_limits_channel',
      'Límites de Bienestar Digital',
      channelDescription:
          'Notificaciones de alerta cuando una aplicación supera el límite configurado.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
      windows: WindowsNotificationDetails(),
    );

    final hours = limitMinutes ~/ 60;
    final mins = limitMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    await _notificationsPlugin.show(
      id: notificationId,
      title: 'Límite de tiempo alcanzado: $appName',
      body:
          'Has alcanzado el límite diario de $timeStr configurado para $appName. Es momento de un descanso.',
      notificationDetails: notificationDetails,
    );
  }
}
