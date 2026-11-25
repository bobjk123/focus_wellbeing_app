import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_bloc.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_event.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_state.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/presentation/bloc/digital_wellbeing_bloc.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/presentation/bloc/digital_wellbeing_event.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/presentation/bloc/digital_wellbeing_state.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:focus_wellbeing_app/features/focus_pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:focus_wellbeing_app/features/shared/presentation/pages/dashboard_page.dart';
import 'package:focus_wellbeing_app/features/shared/presentation/widgets/skeleton_box.dart';
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
  late MockPomodoroBloc mockPomodoroBloc;
  late MockCalendarSyncBloc mockCalendarSyncBloc;
  late MockDigitalWellbeingBloc mockWellbeingBloc;

  setUp(() {
    mockPomodoroBloc = MockPomodoroBloc();
    mockCalendarSyncBloc = MockCalendarSyncBloc();
    mockWellbeingBloc = MockDigitalWellbeingBloc();

    when(() => mockPomodoroBloc.state).thenReturn(PomodoroInitialState());
    when(() => mockCalendarSyncBloc.state)
        .thenReturn(CalendarSyncInitialState());
    when(() => mockWellbeingBloc.state).thenReturn(WellbeingLoadingState());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PomodoroBloc>.value(value: mockPomodoroBloc),
          BlocProvider<CalendarSyncBloc>.value(value: mockCalendarSyncBloc),
          BlocProvider<DigitalWellbeingBloc>.value(value: mockWellbeingBloc),
        ],
        child: const DashboardPage(),
      ),
    );
  }

  testWidgets('muestra Skeletons y estado vacío de Calendar al iniciar',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byType(DashboardCardSkeleton), findsNWidgets(2));
    expect(find.text('Sin bloques de enfoque agendados'), findsOneWidget);
    expect(find.text('Buscar horario'), findsOneWidget);
  });

  testWidgets('usa NavigationBar en móvil y NavigationRail en escritorio',
      (tester) async {
    tester.view.physicalSize = const Size(420, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildSubject());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    tester.view.physicalSize = const Size(1100, 800);
    await tester.pump();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('muestra estado de error de Calendar con botón Reintentar',
      (tester) async {
    when(() => mockCalendarSyncBloc.state).thenReturn(
      CalendarSyncErrorState('Inicio de sesión cancelado por el usuario.'),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Error en Google Calendar'), findsOneWidget);
    expect(
        find.text('Inicio de sesión cancelado por el usuario.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
