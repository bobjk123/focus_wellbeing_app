// lib/features/digital_wellbeing/domain/entities/app_usage_entity.dart

class AppUsageEntity {
  final String packageName;
  final String appName;
  final int usageMinutes;
  final int limitMinutes;
  final bool isBlocked;

  AppUsageEntity({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
    required this.limitMinutes,
    required this.isBlocked,
  });

  bool get isLimitExceeded => limitMinutes > 0 && usageMinutes >= limitMinutes;
  double get progress =>
      limitMinutes == 0 ? 0 : (usageMinutes / limitMinutes).clamp(0.0, 1.0);
}
