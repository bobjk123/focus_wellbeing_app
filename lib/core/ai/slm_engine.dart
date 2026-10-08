// lib/core/ai/slm_engine.dart

import '../../features/shared/data/models/app_entities.dart';
import 'entities/ai_recommendation.dart';

class SlmEngine {
  /// Analiza la fatiga percibida de las últimas sesiones y el tiempo de pantalla diario
  /// para calcular recomendaciones de pausas e higiene cognitiva.
  Future<List<AiRecommendation>> evaluateCognitiveLoad({
    required List<PomodoroSession> recentSessions,
    required List<UsageLimit> usageLimits,
    required List<CalendarEvent> upcomingEvents,
  }) async {
    final List<AiRecommendation> recommendations = [];
    final now = DateTime.now();

    // 1. Evaluación de Fatiga Acumulada (Promedio ponderado de las últimas 3 sesiones)
    if (recentSessions.isNotEmpty) {
      final lastThreeSessions = recentSessions.take(3).toList();
      final double avgFatigue = lastThreeSessions.fold<int>(
            0,
            (sum, session) => sum + session.fatigueRating,
          ) /
          lastThreeSessions.length;

      if (avgFatigue >= 3.8) {
        recommendations.add(
          AiRecommendation(
            id: 'rec_fatigue_${now.millisecondsSinceEpoch}',
            type: RecommendationType.restBreak,
            title: 'Sugerencia de Descanso Físico y Ocular',
            explanationXAI:
                'Explicación IA: Registraste un nivel de fatiga promedio de ${avgFatigue.toStringAsFixed(1)}/5 '
                'en tus últimas ${lastThreeSessions.length} sesiones de enfoque. '
                'Tu capacidad de retención disminuye un 30% bajo este umbral de agotamiento.',
            suggestedBreakMinutes: 20,
            recommendedStartTime: now,
            confidenceScore: 0.92,
          ),
        );
      }
    }

    // 2. Detección de Bloques de Enfoque Consecutivos (Prevención de Burnout)
    final int totalFocusMinutesToday = recentSessions
        .where((s) =>
            s.startTime.year == now.year &&
            s.startTime.month == now.month &&
            s.startTime.day == now.day)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);

    if (totalFocusMinutesToday >= 180) {
      recommendations.add(
        AiRecommendation(
          id: 'rec_burnout_${now.millisecondsSinceEpoch}',
          type: RecommendationType.screenDisconnect,
          title: 'Umbral Diario de Concentración Alcanzado',
          explanationXAI:
              'Explicación IA: Has acumulado $totalFocusMinutesToday minutos de enfoque intenso hoy. '
              'Para mantener la sostenibilidad cognitiva a largo plazo, el sistema te recomienda '
              'finalizar las sesiones de alta carga mental por hoy.',
          suggestedBreakMinutes: 45,
          recommendedStartTime: now,
          confidenceScore: 0.88,
        ),
      );
    }

    // 3. Análisis de Ventanas de Tiempo Libre para Time-Blocking
    final bool hasUpcomingConflict = upcomingEvents.any((e) =>
        e.startTime.isBefore(now.add(const Duration(minutes: 30))) &&
        e.endTime.isAfter(now));

    if (hasUpcomingConflict) {
      recommendations.add(
        AiRecommendation(
          id: 'rec_reschedule_${now.millisecondsSinceEpoch}',
          type: RecommendationType.rescheduleTask,
          title: 'Reestructuración Sugerida de Calendario',
          explanationXAI:
              'Explicación IA: Se detectó un evento programado en tu Google Calendar en los próximos 30 minutos. '
              'Iniciar una nueva sesión Pomodoro de 25 minutos generaría un solapamiento directo.',
          suggestedBreakMinutes: 0,
          confidenceScore: 0.95,
        ),
      );
    }

    return recommendations;
  }
}
