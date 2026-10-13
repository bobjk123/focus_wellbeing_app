// lib/features/reports/presentation/pages/weekly_reports_page.dart

import 'package:flutter/material.dart';

class WeeklyReportsPage extends StatefulWidget {
  const WeeklyReportsPage({super.key});

  @override
  State<WeeklyReportsPage> createState() => _WeeklyReportsPageState();
}

class _WeeklyReportsPageState extends State<WeeklyReportsPage> {
  // Datos semanales de tiempo de enfoque (Minutos por día: Lun - Dom)
  final List<double> _weeklyFocusMinutes = [120, 150, 90, 200, 180, 60, 45];
  final List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  // Datos de cumplimiento de límites por App
  final List<Map<String, dynamic>> _appUsageLimits = [
    {
      'name': 'Instagram',
      'icon': Icons.camera_alt_outlined,
      'usedMinutes': 45,
      'limitMinutes': 30,
      'exceeded': true,
    },
    {
      'name': 'YouTube',
      'icon': Icons.play_circle_outline,
      'usedMinutes': 40,
      'limitMinutes': 60,
      'exceeded': false,
    },
    {
      'name': 'X (Twitter)',
      'icon': Icons.alternate_email,
      'usedMinutes': 20,
      'limitMinutes': 30,
      'exceeded': false,
    },
  ];

  int get _totalFocusMinutes =>
      _weeklyFocusMinutes.reduce((a, b) => a + b).toInt();

  double get _maxFocusValue =>
      _weeklyFocusMinutes.reduce((a, b) => a > b ? a : b);

  String _formatHoursAndMins(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Estadísticas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Resumen Semanal de Enfoque
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de Enfoque Esta Semana',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatHoursAndMins(_totalFocusMinutes),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gráfico de Barras Semanal
                    SizedBox(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children:
                            List.generate(_weeklyFocusMinutes.length, (index) {
                          final value = _weeklyFocusMinutes[index];
                          final heightFactor =
                              (value / _maxFocusValue).clamp(0.1, 1.0);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${value.toInt()}m',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 22,
                                height: 80 * heightFactor,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _weekDays[index],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Sección de Cumplimiento de Límites por Aplicación
            Text(
              'Límites y Bienestar por App',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._appUsageLimits.map((app) {
              final int used = app['usedMinutes'];
              final int limit = app['limitMinutes'];
              final bool exceeded = app['exceeded'];
              final double progress = (used / limit).clamp(0.0, 1.0);

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: exceeded
                        ? theme.colorScheme.error
                        : theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                app['icon'] as IconData,
                                color: exceeded
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                app['name'] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Chip(
                            padding: EdgeInsets.zero,
                            label: Text(
                              exceeded ? 'Excedido' : 'En límite',
                              style: TextStyle(
                                fontSize: 11,
                                color: exceeded
                                    ? theme.colorScheme.onErrorContainer
                                    : theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            backgroundColor: exceeded
                                ? theme.colorScheme.errorContainer
                                : theme.colorScheme.secondaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          exceeded
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uso: ${used}m / Límite: ${limit}m',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
