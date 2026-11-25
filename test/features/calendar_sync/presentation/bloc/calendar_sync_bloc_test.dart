import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/core/network/google_calendar_exceptions.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/data/repositories/calendar_sync_repository.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/domain/entities/focus_schedule_proposal.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_bloc.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_event.dart';
import 'package:focus_wellbeing_app/features/calendar_sync/presentation/bloc/calendar_sync_state.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarSyncRepository extends Mock
    implements CalendarSyncRepository {}

void main() {
  late CalendarSyncBloc bloc;
  late MockCalendarSyncRepository mockRepository;

  final now = DateTime(2026, 11, 25, 10, 0);
  final proposal = FocusScheduleProposal(
    taskId: 't1',
    taskTitle: 'Estudio',
    proposedStart: now,
    proposedEnd: now.add(const Duration(minutes: 25)),
    xaiReasoning: 'Espacio libre.',
    hasConflict: false,
  );

  setUpAll(() {
    registerFallbackValue(proposal);
  });

  setUp(() {
    mockRepository = MockCalendarSyncRepository();
    bloc = CalendarSyncBloc(repository: mockRepository);
  });

  tearDown(() => bloc.close());

  group('CalendarSyncBloc', () {
    blocTest<CalendarSyncBloc, CalendarSyncState>(
      'emite [Loading, ProposalGenerated] cuando calcula el espacio correctamente',
      build: () {
        when(() => mockRepository.calculateOptimalFocusSlot(
              taskId: any(named: 'taskId'),
              taskTitle: any(named: 'taskTitle'),
              durationMinutes: any(named: 'durationMinutes'),
              preferredStart: any(named: 'preferredStart'),
            )).thenAnswer((_) async => proposal);
        return bloc;
      },
      act: (b) => b.add(RequestFocusBlockScheduleEvent(
        taskId: 't1',
        taskTitle: 'Estudio',
        durationMinutes: 25,
        preferredStart: now,
      )),
      expect: () => [
        isA<CalendarSyncLoadingState>(),
        isA<ProposalGeneratedState>(),
      ],
    );

    blocTest<CalendarSyncBloc, CalendarSyncState>(
      'emite [Loading, Error] con mensaje claro cuando ocurre CalendarAuthException',
      build: () {
        when(() => mockRepository.calculateOptimalFocusSlot(
              taskId: any(named: 'taskId'),
              taskTitle: any(named: 'taskTitle'),
              durationMinutes: any(named: 'durationMinutes'),
              preferredStart: any(named: 'preferredStart'),
            )).thenThrow(const CalendarAuthException(
          type: CalendarAuthErrorType.canceled,
          message: 'Inicio de sesión cancelado por el usuario.',
        ));
        return bloc;
      },
      act: (b) => b.add(RequestFocusBlockScheduleEvent(
        taskId: 't1',
        taskTitle: 'Estudio',
        durationMinutes: 25,
        preferredStart: now,
      )),
      expect: () => [
        isA<CalendarSyncLoadingState>(),
        predicate<CalendarSyncState>((s) =>
            s is CalendarSyncErrorState &&
            s.message == 'Inicio de sesión cancelado por el usuario.'),
      ],
    );

    blocTest<CalendarSyncBloc, CalendarSyncState>(
      'emite [Loading, ScheduleConfirmed] al confirmar propuesta',
      build: () {
        when(() => mockRepository.confirmAndScheduleBlock(any()))
            .thenAnswer((_) async => 'gcal-event-123');
        return bloc;
      },
      act: (b) => b.add(ConfirmScheduleProposalEvent(proposal)),
      expect: () => [
        isA<CalendarSyncLoadingState>(),
        predicate<CalendarSyncState>((s) =>
            s is ScheduleConfirmedState && s.googleEventId == 'gcal-event-123'),
      ],
    );
  });
}
