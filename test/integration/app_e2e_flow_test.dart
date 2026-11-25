import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_bloc.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_event.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_state.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/domain/entities/app_usage_entity.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/presentation/bloc/digital_wellbeing_bloc.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/presentation/bloc/digital_wellbeing_event.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/presentation/bloc/digital_wellbeing_state.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:focus_wellbeing_app/features/shared/presentation/pages/dashboard_page.dart';
import 'package:mocktail/mocktail.dart';

class MockPomodoroBloc extends MockBloc<PomodoroEvent, PomodoroState>
    implements PomodoroBloc {}

class MockCalendarSyncBloc
    extends MockBloc<CalendarSyncEvent, CalendarSyncState>
    implements CalendarSyncBloc {}

class MockDigitalWellbeingBloc
    extends MockBloc<DigitalWellbeingEvent, DigitalWellbeingState>
    implements DigitalWellbeingBloc {}

void main() {
  testWidgets(
      'Flujo E2E completo: navega por Inicio, Bosque, Bienestar, Reportes y abre Temporizador',
      (tester) async {
    final pomodoroBloc = MockPomodoroBloc();
    final calendarBloc = MockCalendarSyncBloc();
    final wellbeingBloc = MockDigitalWellbeingBloc();

    when(() => pomodoroBloc.state).thenReturn(
      DailyForestStatsLoadedState(treesPlanted: 2, focusMinutes: 50),
    );
    when(() => calendarBloc.state).thenReturn(CalendarSyncInitialState());
    when(() => wellbeingBloc.state).thenReturn(
      WellbeingLoadedState(
        totalScreenTimeMinutes: 45,
        appUsages: [
          AppUsageEntity(
            packageName: 'com.instagram.android',
            appName: 'Instagram',
            usageMinutes: 45,
            limitMinutes: 30,
            isBlocked: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PomodoroBloc>.value(value: pomodoroBloc),
            BlocProvider<CalendarSyncBloc>.value(value: calendarBloc),
            BlocProvider<DigitalWellbeingBloc>.value(value: wellbeingBloc),
          ],
          child: const DashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verificar pantalla de Inicio
    expect(find.text('2 árboles plantados (50 min de enfoque)'), findsOneWidget);
    expect(find.text('45 min consumidos hoy'), findsOneWidget);

    // 2. Navegar a Bosque
    await tester.tap(find.text('Bosque'));
    await tester.pumpAndSettle();
    expect(find.text('Mi Bosque Virtual'), findsOneWidget);

    // 3. Navegar a Bienestar
    await tester.tap(find.text('Bienestar'));
    await tester.pumpAndSettle();
    expect(find.text('Instagram'), findsOneWidget);

    // 4. Navegar a Reportes
    await tester.tap(find.text('Reportes'));
    await tester.pumpAndSettle();
    expect(find.text('Reportes y Estadísticas'), findsOneWidget);

    // 5. Regresar a Inicio y abrir Temporizador Pomodoro
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar Enfoque'));
    await tester.pumpAndSettle();
    expect(find.text('Sesión de Enfoque - Desarrollo de App Flutter'),
        findsOneWidget);
  });
}
