// lib/features/digital_wellbeing/data/repositories/usage_repository_impl.dart

import '../../domain/entities/app_usage_entity.dart';
import '../../domain/repositories/usage_repository.dart';
import '../datasources/usage_stats_local_datasource.dart';

class UsageRepositoryImpl implements UsageRepository {
  final UsageStatsLocalDataSource localDataSource;

  UsageRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AppUsageEntity>> getDailyUsageStats() async {
    final limits = await localDataSource.getUsageLimits();

    // Si no existen registros aún, se provee una lista inicial por defecto
    if (limits.isEmpty) {
      return [
        AppUsageEntity(
          packageName: 'com.instagram.android',
          appName: 'Instagram',
          usageMinutes: 45,
          limitMinutes: 30,
          isBlocked: true,
        ),
        AppUsageEntity(
          packageName: 'com.google.android.youtube',
          appName: 'YouTube',
          usageMinutes: 20,
          limitMinutes: 60,
          isBlocked: false,
        ),
        AppUsageEntity(
          packageName: 'com.twitter.android',
          appName: 'X (Twitter)',
          usageMinutes: 15,
          limitMinutes: 0,
          isBlocked: false,
        ),
      ];
    }

    // Mapeo de modelos Isar DB a Entidades del Dominio
    return limits.map((model) {
      final isExceeded = model.dailyLimitMinutes > 0 &&
          model.currentUsageMinutes >= model.dailyLimitMinutes;

      return AppUsageEntity(
        packageName: model.packageName,
        appName: model.appName,
        usageMinutes: model.currentUsageMinutes,
        limitMinutes: model.dailyLimitMinutes,
        isBlocked: isExceeded,
      );
    }).toList();
  }

  @override
  Future<void> setAppUsageLimit(
    String packageName,
    String appName,
    int limitMinutes,
  ) async {
    await localDataSource.saveOrUpdateLimit(
      packageName: packageName,
      appName: appName,
      limitMinutes: limitMinutes,
    );
  }
}
