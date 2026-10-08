// lib/injection_container.dart

import 'package:focus_wellbeing_app/core/network/google_calendar_client.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/data/repositories/calendar_sync_repository.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/domain/usescases/complete_pomodoro_session_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

import 'features/focus_pomodoro/data/datasources/calendar_remote_datasource.dart';
import 'features/focus_pomodoro/data/datasources/pomodoro_local_datasource.dart';
import 'features/focus_pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'features/focus_pomodoro/domain/repositories/pomodoro_repository.dart';
import 'features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'core/ai/slm_engine.dart';
import 'features/digital_wellbeing/data/datasources/usage_stats_local_datasource.dart';
import 'features/digital_wellbeing/data/repositories/usage_repository_impl.dart';
import 'features/digital_wellbeing/domain/repositories/usage_repository.dart';
import 'features/digital_wellbeing/domain/usecases/get_usage_stats_usecase.dart';
import 'features/digital_wellbeing/domain/usecases/set_app_limit_usecase.dart';
import 'features/digital_wellbeing/presentation/bloc/digital_wellbeing_bloc.dart';
import 'features/calendar_sync/data/datasources/calendar_sync_remote_datasource.dart';
import 'features/calendar_sync/data/repositories/calendar_sync_repository_impl.dart';
import 'features/calendar_sync/presentation/bloc/calendar_sync_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initServiceLocator(Isar isarInstance) async {
  // Motor On-Device AI / SLM
  sl.registerLazySingleton<SlmEngine>(() => SlmEngine());
  // 1. Instancia compartida de Isar DB
  sl.registerLazySingleton<Isar>(() => isarInstance);

  // Client HTTP de Google Calendar
  sl.registerLazySingleton<GoogleCalendarClient>(() => GoogleCalendarClient());

  // DataSources
  sl.registerLazySingleton<PomodoroLocalDataSource>(
    () => PomodoroLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () =>
        CalendarRemoteDataSourceImpl(sl()), // Recibe sl<GoogleCalendarClient>()
  );
  // 3. Repositorios
  sl.registerLazySingleton<PomodoroRepository>(
    () => PomodoroRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // 4. Casos de Uso
  sl.registerLazySingleton<CompletePomodoroSessionUseCase>(
    () => CompletePomodoroSessionUseCase(sl()),
  );

  // 5. BLoCs (Factory para crear instancias nuevas cuando la UI lo requiera)
  sl.registerFactory<PomodoroBloc>(
    () => PomodoroBloc(completePomodoroSessionUseCase: sl()),
  );

  // 1. Data Source de Bienestar Digital
  sl.registerLazySingleton<UsageStatsLocalDataSource>(
    () => UsageStatsLocalDataSourceImpl(sl()),
  );

  // 2. Repositorio de Bienestar Digital
  sl.registerLazySingleton<UsageRepository>(
    () => UsageRepositoryImpl(localDataSource: sl()),
  );

  // 3. Casos de Uso
  sl.registerLazySingleton<GetUsageStatsUseCase>(
    () => GetUsageStatsUseCase(sl()),
  );
  sl.registerLazySingleton<SetAppLimitUseCase>(
    () => SetAppLimitUseCase(sl()),
  );

  // 4. BLoC
  sl.registerFactory<DigitalWellbeingBloc>(
    () => DigitalWellbeingBloc(
      getUsageStatsUseCase: sl(),
      setAppLimitUseCase: sl(),
    ),
  );

  // Data Source de Sincronización
  sl.registerLazySingleton<CalendarSyncRemoteDataSource>(
    () => CalendarSyncRemoteDataSourceImpl(sl()),
  );

  // Repositorio
  sl.registerLazySingleton<CalendarSyncRepository>(
    () => CalendarSyncRepositoryImpl(remoteDataSource: sl()),
  );

  // BLoC
  sl.registerFactory<CalendarSyncBloc>(
    () => CalendarSyncBloc(repository: sl()),
  );
}
