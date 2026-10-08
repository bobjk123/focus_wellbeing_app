// lib/features/digital_wellbeing/presentation/bloc/digital_wellbeing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_usage_stats_usecase.dart';
import '../../domain/usecases/set_app_limit_usecase.dart';
import 'digital_wellbeing_event.dart';
import 'digital_wellbeing_state.dart';

class DigitalWellbeingBloc
    extends Bloc<DigitalWellbeingEvent, DigitalWellbeingState> {
  final GetUsageStatsUseCase getUsageStatsUseCase;
  final SetAppLimitUseCase setAppLimitUseCase;

  DigitalWellbeingBloc({
    required this.getUsageStatsUseCase,
    required this.setAppLimitUseCase,
  }) : super(WellbeingLoadingState()) {
    on<LoadUsageStatsEvent>(_onLoadUsageStats);
    on<UpdateAppLimitEvent>(_onUpdateAppLimit);
  }

  Future<void> _onLoadUsageStats(
    LoadUsageStatsEvent event,
    Emitter<DigitalWellbeingState> emit,
  ) async {
    emit(WellbeingLoadingState());
    try {
      final usages = await getUsageStatsUseCase();
      final totalMinutes =
          usages.fold<int>(0, (sum, item) => sum + item.usageMinutes);
      emit(WellbeingLoadedState(
          appUsages: usages, totalScreenTimeMinutes: totalMinutes));
    } catch (e) {
      emit(WellbeingErrorState("Error al cargar estadísticas de uso: $e"));
    }
  }

  Future<void> _onUpdateAppLimit(
    UpdateAppLimitEvent event,
    Emitter<DigitalWellbeingState> emit,
  ) async {
    try {
      await setAppLimitUseCase(
          event.packageName, event.appName, event.limitMinutes);
      add(LoadUsageStatsEvent()); // Recargar estadísticas tras actualizar
    } catch (e) {
      emit(WellbeingErrorState("No se pudo actualizar el límite: $e"));
    }
  }
}
