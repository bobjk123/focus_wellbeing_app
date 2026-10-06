// lib/features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/domain/usescases/complete_pomodoro_session_usecase.dart';
import 'pomodoro_event.dart';
import 'pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final CompletePomodoroSessionUseCase completePomodoroSessionUseCase;

  PomodoroBloc({required this.completePomodoroSessionUseCase})
      : super(PomodoroInitialState()) {
    on<FinishPomodoroSessionEvent>(_onFinishSession);
  }

  Future<void> _onFinishSession(
    FinishPomodoroSessionEvent event,
    Emitter<PomodoroState> emit,
  ) async {
    emit(PomodoroSyncingState());

    try {
      await completePomodoroSessionUseCase(
        CompletePomodoroSessionParams(
          taskId: event.taskId,
          taskTitle: event.taskTitle,
          durationMinutes: event.durationMinutes,
          fatigueRating: event.fatigueRating,
          treeSpecies: event.treeSpecies,
        ),
      );

      // Evaluación de fatiga para recomendación de descanso (IA Ética / Higiene Cognitiva)
      String aiMessage =
          "¡Excelente trabajo! Has mantenido la concentración durante toda la sesión.";
      if (event.fatigueRating >= 4) {
        aiMessage = "Detección de fatiga elevada (${event.fatigueRating}/5). "
            "Explicación IA: Tu nivel acumulado de cansancio puede comprometer tu claridad mental. "
            "Te recomendamos realizar una pausa de 15 minutos sin pantallas.";
      }

      emit(
        PomodoroCompletedState(
          treePlantedMessage:
              "Árbol '${event.treeSpecies}' plantado con éxito en tu bosque local.",
          calendarSyncMessage:
              "Bloque de tiempo de ${event.durationMinutes} min registrado en Google Calendar.",
          aiRestRecommendation: aiMessage,
        ),
      );
    } catch (e) {
      emit(PomodoroErrorState("Error al procesar el cierre de la sesión: $e"));
    }
  }
}
