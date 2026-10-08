// lib/features/digital_wellbeing/presentation/bloc/digital_wellbeing_event.dart

abstract class DigitalWellbeingEvent {}

class LoadUsageStatsEvent extends DigitalWellbeingEvent {}

class UpdateAppLimitEvent extends DigitalWellbeingEvent {
  final String packageName;
  final String appName;
  final int limitMinutes;

  UpdateAppLimitEvent({
    required this.packageName,
    required this.appName,
    required this.limitMinutes,
  });
}
