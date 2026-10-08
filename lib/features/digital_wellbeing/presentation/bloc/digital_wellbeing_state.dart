// lib/features/digital_wellbeing/presentation/bloc/digital_wellbeing_state.dart

import '../../domain/entities/app_usage_entity.dart';

abstract class DigitalWellbeingState {}

class WellbeingLoadingState extends DigitalWellbeingState {}

class WellbeingLoadedState extends DigitalWellbeingState {
  final List<AppUsageEntity> appUsages;
  final int totalScreenTimeMinutes;

  WellbeingLoadedState({
    required this.appUsages,
    required this.totalScreenTimeMinutes,
  });
}

class WellbeingErrorState extends DigitalWellbeingState {
  final String message;
  WellbeingErrorState(this.message);
}
