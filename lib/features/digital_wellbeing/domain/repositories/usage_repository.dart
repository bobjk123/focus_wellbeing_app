// lib/features/digital_wellbeing/domain/repositories/usage_repository.dart

import '../entities/app_usage_entity.dart';

abstract class UsageRepository {
  Future<List<AppUsageEntity>> getDailyUsageStats();
  Future<void> setAppUsageLimit(
      String packageName, String appName, int limitMinutes);
}
