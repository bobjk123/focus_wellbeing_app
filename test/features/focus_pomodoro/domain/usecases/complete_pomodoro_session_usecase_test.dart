// test/features/focus_pomodoro/domain/usecases/complete_pomodoro_session_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/domain/usescases/complete_pomodoro_session_usecase.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:mocktail/mocktail.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/domain/repositories/pomodoro_repository.dart';

// Definición del Mock para el Repositorio
class MockPomodoroRepository extends Mock implements PomodoroRepository {}

class FakePomodoroSession extends Fake implements PomodoroSession {}

void main() {
  late CompletePomodoroSessionUseCase usecase;
  late MockPomodoroRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakePomodoroSession());
  });

  setUp(() {
    mockRepository = MockPomodoroRepository();
    usecase = CompletePomodoroSessionUseCase(mockRepository);
  });

  final tParams = CompletePomodoroSessionParams(
    taskId: 'task_123',
    taskTitle: 'Desarrollo de Unit Tests',
    durationMinutes: 25,
    fatigueRating: 2,
    treeSpecies: 'Roble Nobilis',
  );

  test(
    'Debe llamar a saveCompletedSession en el repositorio con los parámetros adecuados',
    () async {
      // Arrange (Preparar)
      when(() => mockRepository.saveCompletedSession(
            session: any(named: 'session'),
            treeSpecies: any(named: 'treeSpecies'),
            taskTitle: any(named: 'taskTitle'),
          )).thenAnswer((_) async => Future.value());

      // Act (Ejecutar)
      await usecase(tParams);

      // Assert (Verificar)
      verify(() => mockRepository.saveCompletedSession(
            session: any(named: 'session'),
            treeSpecies: tParams.treeSpecies,
            taskTitle: tParams.taskTitle,
          )).called(1);

      verifyNoMoreInteractions(mockRepository);
    },
  );
}
