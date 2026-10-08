// lib/features/digital_wellbeing/presentation/pages/digital_wellbeing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/digital_wellbeing_bloc.dart';
import '../bloc/digital_wellbeing_event.dart';
import '../bloc/digital_wellbeing_state.dart';
import '../../domain/entities/app_usage_entity.dart';

class DigitalWellbeingPage extends StatefulWidget {
  const DigitalWellbeingPage({super.key});

  @override
  State<DigitalWellbeingPage> createState() => _DigitalWellbeingPageState();
}

class _DigitalWellbeingPageState extends State<DigitalWellbeingPage> {
  @override
  void initState() {
    super.initState();
    context.read<DigitalWellbeingBloc>().add(LoadUsageStatsEvent());
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienestar Digital'),
        centerTitle: true,
      ),
      body: BlocConsumer<DigitalWellbeingBloc, DigitalWellbeingState>(
        listener: (context, state) {
          if (state is WellbeingErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WellbeingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WellbeingLoadedState) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DigitalWellbeingBloc>().add(LoadUsageStatsEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 1. Resumen de tiempo de pantalla total
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Tiempo de pantalla hoy',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatMinutes(state.totalScreenTimeMinutes),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Límites de Aplicaciones',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 2. Lista de aplicaciones y controles de límite
                  ...state.appUsages
                      .map((usage) => _buildAppLimitTile(context, usage)),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAppLimitTile(BuildContext context, AppUsageEntity usage) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: usage.isLimitExceeded
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
                      usage.isLimitExceeded ? Icons.block : Icons.apps,
                      color: usage.isLimitExceeded
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      usage.appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatMinutes(usage.usageMinutes),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: usage.progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                usage.isLimitExceeded
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  usage.limitMinutes > 0
                      ? 'Límite: ${_formatMinutes(usage.limitMinutes)}'
                      : 'Sin límite configurado',
                  style: theme.textTheme.bodySmall,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text('Ajustar'),
                  onPressed: () => _showLimitDialog(context, usage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitDialog(BuildContext context, AppUsageEntity usage) {
    int selectedMinutes = usage.limitMinutes == 0 ? 30 : usage.limitMinutes;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Límite para ${usage.appName}'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_formatMinutes(selectedMinutes)} al día'),
                Slider(
                  value: selectedMinutes.toDouble(),
                  min: 0,
                  max: 240,
                  divisions: 16,
                  label: _formatMinutes(selectedMinutes),
                  onChanged: (value) {
                    setDialogState(() => selectedMinutes = value.toInt());
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<DigitalWellbeingBloc>().add(
                    UpdateAppLimitEvent(
                      packageName: usage.packageName,
                      appName: usage.appName,
                      limitMinutes: selectedMinutes,
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
