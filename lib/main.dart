// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart' as di;
import 'core/database/sqlite_database.dart';
import 'features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'features/digital_wellbeing/presentation/bloc/digital_wellbeing_bloc.dart';
import 'features/calendar_sync/presentation/bloc/calendar_sync_bloc.dart';
import 'features/shared/presentation/pages/dashboard_page.dart';
import 'core/notifications/notification_service.dart';
import 'core/background/workmanager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WorkmanagerService.initialize();
  await WorkmanagerService.registerPeriodicScreenTimeCheck();

  // 1. Inicializar servicio de notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // 2. Abrir la base de datos SQLite protegida con SQLCipher/AES-256
  final database = await SqliteDatabase.open();

  // 3. Inicializar Inyección de Dependencias (Service Locator)
  await di.initServiceLocator(database, notificationService);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final Widget? home;

  const MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus & Wellbeing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: home ??
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<DigitalWellbeingBloc>()),
              BlocProvider(create: (_) => di.sl<CalendarSyncBloc>()),
              BlocProvider(create: (_) => di.sl<PomodoroBloc>()),
            ],
            child: const DashboardPage(),
          ),
    );
  }
}
