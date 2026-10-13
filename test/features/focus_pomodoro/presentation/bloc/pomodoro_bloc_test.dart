// test/features/focus_pomodoro/presentation/bloc/pomodoro_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/domain/usescases/complete_pomodoro_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

class MockCompletePomodoroSessionUseCase extends Mock
    implements CompletePomodoroSessionUseCase {}

class FakeCompletePomodoroSessionParams extends Fake
    implements CompletePomodoroSessionParams {}

void main() {
  late PomodoroBloc pomodoroBloc;
  late MockCompletePomodoroSessionUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(FakeCompletePomodoroSessionParams());
  });

  setUp(() {
    mockUseCase = MockCompletePomodoroSessionUseCase();
    pomodoroBloc = PomodoroBloc(completePomodoroSessionUseCase: mockUseCase);
  });

  tearDown(() {
    pomodoroBloc.close();
  });

  test('El estado inicial debe ser PomodoroInitialState', () {
    expect(pomodoroBloc.state, isA<PomodoroInitialState>());
  });

  group('FinishPomodoroSessionEvent Tests', () {
    final tEvent = FinishPomodoroSessionEvent(
      taskId: 'task_001',
      taskTitle: 'Test BLoC',
      durationMinutes: 25,
      fatigueRating: 2,
      treeSpecies: 'Pino Silvestre',
    );

    blocTest<PomodoroBloc, PomodoroState>(
      'Debe emitir [PomodoroSyncingState, PomodoroCompletedState] cuando la sesión se completa con éxito',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => Future.value());
        return pomodoroBloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<PomodoroSyncingState>(),
        isA<PomodoroCompletedState>(),
      ],
      verify: (_) {
        verify(() => mockUseCase(any())).called(1);
      },
    );

    blocTest<PomodoroBloc, PomodoroState>(
      'Debe incluir mensaje de alerta de fatiga en la recomendación de IA si fatigueRating >= 4',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => Future.value());
        return pomodoroBloc;
      },
      act: (bloc) => bloc.add(
        FinishPomodoroSessionEvent(
          taskId: 'task_002',
          taskTitle: 'Sesión Intensa',
          durationMinutes: 50,
          fatigueRating: 5, // Cansancio elevado
          treeSpecies: 'Bonsai Zen',
        ),
      ),
      expect: () => [
        isA<PomodoroSyncingState>(),
        predicate<PomodoroCompletedState>((state) {
          return state.aiRestRecommendation
              .contains('Detección de fatiga elevada');
        }),
      ],
    );

    blocTest<PomodoroBloc, PomodoroState>(
      'Debe emitir [PomodoroSyncingState, PomodoroErrorState] cuando el caso de uso arroja una excepción',
      build: () {
        when(() => mockUseCase(any()))
            .thenThrow(Exception('Error de base de datos'));
        return pomodoroBloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        isA<PomodoroSyncingState>(),
        isA<PomodoroErrorState>(),
      ],
    );
  });
}
