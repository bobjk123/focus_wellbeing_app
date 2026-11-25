import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../calendar_sync/presentation/bloc/calendar_sync_bloc.dart';
import '../../../calendar_sync/presentation/bloc/calendar_sync_event.dart';
import '../../../calendar_sync/presentation/bloc/calendar_sync_state.dart';
import '../../../digital_wellbeing/presentation/bloc/digital_wellbeing_bloc.dart';
import '../../../digital_wellbeing/presentation/bloc/digital_wellbeing_state.dart';
import '../../../digital_wellbeing/presentation/pages/digital_wellbeing_page.dart';
import '../../../focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';
import '../../../focus_pomodoro/presentation/bloc/pomodoro_event.dart';
import '../../../focus_pomodoro/presentation/bloc/pomodoro_state.dart';
import '../../../focus_pomodoro/presentation/pages/forest_view_page.dart';
import '../../../focus_pomodoro/presentation/pages/pomodoro_timer_page.dart';
import '../../../reports/presentation/pages/weekly_reports_page.dart';
import '../widgets/skeleton_box.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<PomodoroBloc>().add(LoadDailyForestStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeDashboard(context),
      const ForestViewPage(),
      const DigitalWellbeingPage(),
      const WeeklyReportsPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 700;
        return Scaffold(
          body: Row(
            children: [
              if (useRail)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                  labelType: NavigationRailLabelType.all,
                  destinations: _railDestinations,
                ),
              Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages)),
            ],
          ),
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                  destinations: _bottomDestinations,
                ),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    final pomodoroBloc = context.read<PomodoroBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<PomodoroBloc>.value(
                          value: pomodoroBloc,
                          child: const PomodoroTimerPage(
                            taskId: 'task_001',
                            taskTitle: 'Desarrollo de App Flutter',
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Enfoque'),
                )
              : null,
        );
      },
    );
  }

  static const _bottomDestinations = [
    NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Inicio'),
    NavigationDestination(
        icon: Icon(Icons.park_outlined),
        selectedIcon: Icon(Icons.park),
        label: 'Bosque'),
    NavigationDestination(
        icon: Icon(Icons.screen_search_desktop_outlined),
        selectedIcon: Icon(Icons.screen_search_desktop),
        label: 'Bienestar'),
    NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: 'Reportes'),
  ];

  static const _railDestinations = [
    NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Inicio')),
    NavigationRailDestination(
        icon: Icon(Icons.park_outlined),
        selectedIcon: Icon(Icons.park),
        label: Text('Bosque')),
    NavigationRailDestination(
        icon: Icon(Icons.screen_search_desktop_outlined),
        selectedIcon: Icon(Icons.screen_search_desktop),
        label: Text('Bienestar')),
    NavigationRailDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: Text('Reportes')),
  ];

  void _selectDestination(int index) => setState(() => _selectedIndex = index);

  Widget _buildHomeDashboard(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Mi Espacio de Enfoque'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isWide
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildForestCard()),
                              const SizedBox(width: 20),
                              Expanded(child: _buildWellbeingCard()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildCalendarCard(context),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildForestCard(),
                          const SizedBox(height: 20),
                          _buildCalendarCard(context),
                          const SizedBox(height: 20),
                          _buildWellbeingCard(),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForestCard() {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        if (state is PomodoroInitialState || state is PomodoroSyncingState) {
          return const DashboardCardSkeleton();
        }
        if (state is PomodoroErrorState) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                child: Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.error),
              ),
              title: const Text('Tu Bosque Hoy',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(state.message),
              trailing: TextButton(
                onPressed: () => context
                    .read<PomodoroBloc>()
                    .add(LoadDailyForestStatsEvent()),
                child: const Text('Reintentar'),
              ),
            ),
          );
        }
        final stats = state is DailyForestStatsLoadedState ? state : null;
        return Card(
          color: Colors.green.shade50,
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.park, color: Colors.green),
            ),
            title: const Text('Tu Bosque Hoy',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(stats == null || stats.treesPlanted == 0
                ? 'Aún no has plantado árboles hoy. ¡Inicia una sesión Pomodoro!'
                : '${stats.treesPlanted} árboles plantados (${stats.focusMinutes} min de enfoque)'),
          ),
        );
      },
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return BlocBuilder<CalendarSyncBloc, CalendarSyncState>(
      builder: (context, state) {
        if (state is CalendarSyncLoadingState) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Google Calendar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  LinearProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Evaluando disponibilidad en tu agenda...'),
                ],
              ),
            ),
          );
        }
        if (state is ProposalGeneratedState) {
          final proposal = state.proposal;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.calendar_today),
              title: Text(proposal.hasConflict
                  ? 'Conflicto de tiempo detectado'
                  : 'Próximo bloque de enfoque'),
              subtitle: Text(
                  '${_formatTime(proposal.proposedStart)} - ${_formatTime(proposal.proposedEnd)} | ${proposal.taskTitle}\n${proposal.xaiReasoning}'),
              trailing: FilledButton(
                onPressed: () => context
                    .read<CalendarSyncBloc>()
                    .add(ConfirmScheduleProposalEvent(proposal)),
                child: Text(proposal.hasConflict ? 'Resolver' : 'Agendar'),
              ),
            ),
          );
        }
        if (state is ScheduleConfirmedState) {
          return Card(
              child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading:
                      const Icon(Icons.event_available, color: Colors.green),
                  title: const Text('Bloque agendado'),
                  subtitle: Text(state.message)));
        }
        if (state is CalendarSyncErrorState) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.sync_problem,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Error en Google Calendar'),
              subtitle: Text(state.message),
              trailing: FilledButton.tonal(
                onPressed: () => _requestDefaultSchedule(context),
                child: const Text('Reintentar'),
              ),
            ),
          );
        }
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Sin bloques de enfoque agendados'),
            subtitle: const Text(
                'Conecta tu Google Calendar para buscar un espacio libre y proteger tu tiempo.'),
            trailing: FilledButton(
              onPressed: () => _requestDefaultSchedule(context),
              child: const Text('Buscar horario'),
            ),
          ),
        );
      },
    );
  }

  void _requestDefaultSchedule(BuildContext context) {
    context.read<CalendarSyncBloc>().add(RequestFocusBlockScheduleEvent(
          taskId: 'task_001',
          taskTitle: 'Desarrollo de App Flutter',
          durationMinutes: 25,
          preferredStart: DateTime.now(),
        ));
  }

  Widget _buildWellbeingCard() {
    return BlocBuilder<DigitalWellbeingBloc, DigitalWellbeingState>(
      builder: (context, state) {
        if (state is WellbeingLoadedState) {
          final limitedApps =
              state.appUsages.where((app) => app.limitMinutes > 0);
          final totalLimit =
              limitedApps.fold<int>(0, (sum, app) => sum + app.limitMinutes);
          final progress = totalLimit == 0
              ? 0.0
              : (state.totalScreenTimeMinutes / totalLimit).clamp(0.0, 1.0);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bienestar Digital',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${state.totalScreenTimeMinutes} min consumidos hoy'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress),
                  ]),
            ),
          );
        }
        if (state is WellbeingErrorState) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('Bienestar Digital'),
              subtitle: Text(state.message),
            ),
          );
        }
        return const DashboardCardSkeleton();
      },
    );
  }

  String _formatTime(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
