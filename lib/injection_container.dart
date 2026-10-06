// lib/injection_container.dart

import 'package:focus_wellbeing_app/features/focus_pomodoro/domain/usescases/complete_pomodoro_session_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

import 'features/focus_pomodoro/data/datasources/calendar_remote_datasource.dart';
import 'features/focus_pomodoro/data/datasources/pomodoro_local_datasource.dart';
import 'features/focus_pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'features/focus_pomodoro/domain/repositories/pomodoro_repository.dart';
import 'features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initServiceLocator(Isar isarInstance) async {
  // 1. Instancia compartida de Isar DB
  sl.registerLazySingleton<Isar>(() => isarInstance);

  // 2. DataSources
  sl.registerLazySingleton<PomodoroLocalDataSource>(
    () => PomodoroLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(),
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
}
