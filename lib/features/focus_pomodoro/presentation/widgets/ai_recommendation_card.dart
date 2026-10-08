// lib/features/focus_pomodoro/presentation/widgets/ai_recommendation_card.dart

import 'package:flutter/material.dart';
import '../../../../core/ai/entities/ai_recommendation.dart';

class AiRecommendationCard extends StatelessWidget {
  final AiRecommendation recommendation;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const AiRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withAlpha(128),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.secondary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Cuadro de Justificación Transparente (Explainable AI - XAI)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                recommendation.explanationXAI,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Ignorar por ahora'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    recommendation.suggestedBreakMinutes > 0
                        ? 'Pausa de ${recommendation.suggestedBreakMinutes} min'
                        : 'Aceptar Sugerencia',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
