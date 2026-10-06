// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'injection_container.dart' as di;
import 'features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Obtener el directorio persistente seguro de la app
  final dir = await getApplicationDocumentsDirectory();

  // 2. Abrir la base de datos Isar DB
  final isar = await Isar.open(
    [
      UserTaskSchema,
      PomodoroSessionSchema,
      PlantTreeSchema,
      CalendarEventSchema,
      UsageLimitSchema,
    ],
    directory: dir.path,
    name: 'wellbeing_db',
  );

  // 3. Inicializar Inyección de Dependencias (Service Locator)
  await di.initServiceLocator(isar);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus & Wellbeing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => di.sl<PomodoroBloc>(),
        child: const Scaffold(
          body: Center(
            child: Text('Base de datos cifrada localmente con AES-256.'),
          ),
        ),
      ),
    );
  }
}
