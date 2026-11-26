// lib/features/digital_wellbeing/data/repositories/usage_repository_impl.dart

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/wellbeing/system_usage_stats_service.dart';
import '../../domain/entities/app_usage_entity.dart';
import '../../domain/repositories/usage_repository.dart';
import '../datasources/usage_stats_local_datasource.dart';

class UsageRepositoryImpl implements UsageRepository {
  final UsageStatsLocalDataSource localDataSource;
  final NotificationService notificationService;
  final SystemUsageStatsService? systemUsageService;

  UsageRepositoryImpl({
    required this.localDataSource,
    required this.notificationService,
    this.systemUsageService,
  });

  @override
  Future<List<AppUsageEntity>> getDailyUsageStats() async {
    await _syncWithSystemUsageIfAvailable();
    final limits = await localDataSource.getUsageLimits();

    final result = <AppUsageEntity>[];

    for (var i = 0; i < limits.length; i++) {
      final model = limits[i];
      final isExceeded = model.dailyLimitMinutes > 0 &&
          model.currentUsageMinutes >= model.dailyLimitMinutes;

      // Disparar la notificación si se superó el límite y no estaba previamente bloqueada
      if (isExceeded && !model.isBlocked) {
        await notificationService.showAppLimitExceededNotification(
          notificationId: model.id,
          appName: model.appName,
          limitMinutes: model.dailyLimitMinutes,
        );

        // Actualizar estado para evitar notificaciones repetidas en el mismo día.
        model.isBlocked = true;
        await localDataSource.saveOrUpdateLimit(
          packageName: model.packageName,
          appName: model.appName,
          limitMinutes: model.dailyLimitMinutes,
          isBlocked: true,
        );
      }

      result.add(
        AppUsageEntity(
          packageName: model.packageName,
          appName: model.appName,
          usageMinutes: model.currentUsageMinutes,
          limitMinutes: model.dailyLimitMinutes,
          isBlocked: isExceeded,
        ),
      );
    }

    return result;
  }

  Future<void> _syncWithSystemUsageIfAvailable() async {
    final service = systemUsageService;
    if (service == null) return;

    final hasPermission = await service.hasUsagePermission();
    if (!hasPermission) return;

    final systemStats = await service.getTodayUsageStats();
    if (systemStats.isEmpty) return;

    final existingLimits = await localDataSource.getUsageLimits();
    final existingByPackage = {
      for (final limit in existingLimits) limit.packageName: limit,
    };

    for (final stat in systemStats) {
      final existing = existingByPackage[stat.packageName];
      await localDataSource.saveOrUpdateLimit(
        packageName: stat.packageName,
        appName: stat.appName,
        limitMinutes: existing?.dailyLimitMinutes ?? 0,
        currentUsageMinutes: stat.usageMinutes,
      );
    }
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
