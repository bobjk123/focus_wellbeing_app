// lib/core/ai/entities/ai_recommendation.dart

enum RecommendationType {
  restBreak, // Pausa por fatiga o tiempo prolongado
  rescheduleTask, // Reorganizar bloques de tiempo en el calendario
  screenDisconnect // Alerta de desconexión nocturna / sobreuso
}

class AiRecommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String explanationXAI; // Justificación clara para el usuario (XAI)
  final int suggestedBreakMinutes;
  final DateTime? recommendedStartTime;
  final double confidenceScore;

  AiRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.explanationXAI,
    required this.suggestedBreakMinutes,
    this.recommendedStartTime,
    required this.confidenceScore,
  });
}
