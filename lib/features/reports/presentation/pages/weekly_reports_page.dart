// lib/features/reports/presentation/pages/weekly_reports_page.dart

import 'package:flutter/material.dart';
import 'package:focus_wellbeing_app/core/database/sqlite_database.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:focus_wellbeing_app/features/shared/presentation/widgets/skeleton_box.dart';
import 'package:focus_wellbeing_app/injection_container.dart' as di;

class WeeklyReportsPage extends StatefulWidget {
  final List<double>? initialWeeklyFocusMinutes;
  final List<UsageLimit>? initialUsageLimits;

  const WeeklyReportsPage({
    super.key,
    this.initialWeeklyFocusMinutes,
    this.initialUsageLimits,
  });

  @override
  State<WeeklyReportsPage> createState() => _WeeklyReportsPageState();
}

class _WeeklyReportsPageState extends State<WeeklyReportsPage> {
  static const List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  List<double> _weeklyFocusMinutes = List<double>.filled(7, 0);
  List<UsageLimit> _usageLimits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    if (widget.initialWeeklyFocusMinutes != null &&
        widget.initialUsageLimits != null) {
      setState(() {
        _weeklyFocusMinutes = widget.initialWeeklyFocusMinutes!;
        _usageLimits = widget.initialUsageLimits!;
        _isLoading = false;
      });
      return;
    }

    if (di.sl.isRegistered<SqliteDatabase>()) {
      try {
        final db = di.sl<SqliteDatabase>();
        final weekly = await db.getWeeklyFocusMinutes();
        final limits = await db.getUsageLimits();
        if (!mounted) return;
        setState(() {
          _weeklyFocusMinutes =
              widget.initialWeeklyFocusMinutes ??
                  weekly.map((m) => m.toDouble()).toList();
          _usageLimits = widget.initialUsageLimits ?? limits;
          _isLoading = false;
        });
        return;
      } catch (_) {
        // Fallback a estado vacío si falla la consulta.
      }
    }

    if (mounted) {
      setState(() {
        _weeklyFocusMinutes =
            widget.initialWeeklyFocusMinutes ?? List<double>.filled(7, 0);
        _usageLimits = widget.initialUsageLimits ?? [];
        _isLoading = false;
      });
    }
  }

  int get _totalFocusMinutes =>
      _weeklyFocusMinutes.fold<double>(0, (a, b) => a + b).toInt();

  double get _maxFocusValue {
    final maxVal =
        _weeklyFocusMinutes.fold<double>(0, (a, b) => a > b ? a : b);
    return maxVal <= 0 ? 1 : maxVal;
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar reportes',
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : RefreshIndicator(
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(
                                        _weeklyFocusMinutes.length, (index) {
                                      final value = _weeklyFocusMinutes[index];
                                      final heightFactor = value <= 0
                                          ? 0.08
                                          : (value / _maxFocusValue)
                                              .clamp(0.1, 1.0);

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${value.toInt()}m',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            width: 22,
                                            height: 80 * heightFactor,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme
                                                  .onPrimaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _weekDays[index],
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme
                                                  .onPrimaryContainer,
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

                        if (_usageLimits.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.bar_chart_outlined,
                                      size: 48,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Sin registros de aplicaciones esta semana',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Configura límites en Bienestar Digital o concede acceso a estadísticas del sistema para ver el cumplimiento.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._usageLimits.map((app) {
                            final int used = app.currentUsageMinutes;
                            final int limit = app.dailyLimitMinutes;
                            final bool exceeded =
                                limit > 0 && used >= limit;
                            final double progress = limit <= 0
                                ? 0.0
                                : (used / limit).clamp(0.0, 1.0);

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              exceeded
                                                  ? Icons.block
                                                  : Icons.apps_outlined,
                                              color: exceeded
                                                  ? theme.colorScheme.error
                                                  : theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              app.appName,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Chip(
                                          padding: EdgeInsets.zero,
                                          label: Text(
                                            limit <= 0
                                                ? 'Sin límite'
                                                : exceeded
                                                    ? 'Excedido'
                                                    : 'En límite',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: exceeded
                                                  ? theme.colorScheme
                                                      .onErrorContainer
                                                  : theme.colorScheme
                                                      .onSecondaryContainer,
                                            ),
                                          ),
                                          backgroundColor: exceeded
                                              ? theme
                                                  .colorScheme.errorContainer
                                              : theme.colorScheme
                                                  .secondaryContainer,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        exceeded
                                            ? theme.colorScheme.error
                                            : theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          limit > 0
                                              ? 'Uso: ${used}m / Límite: ${limit}m'
                                              : 'Uso: ${used}m (Sin límite)',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${(progress * 100).toInt()}%',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
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
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: const [
            SkeletonBox(
                height: 220,
                borderRadius: BorderRadius.all(Radius.circular(16))),
            SizedBox(height: 24),
            SkeletonBox(width: 240, height: 22),
            SizedBox(height: 12),
            DashboardCardSkeleton(),
            SizedBox(height: 12),
            DashboardCardSkeleton(),
          ],
        ),
      ),
    );
  }
}
