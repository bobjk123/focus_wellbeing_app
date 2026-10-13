// lib/features/digital_wellbeing/data/repositories/usage_repository_impl.dart

import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/app_usage_entity.dart';
import '../../domain/repositories/usage_repository.dart';
import '../datasources/usage_stats_local_datasource.dart';

class UsageRepositoryImpl implements UsageRepository {
  final UsageStatsLocalDataSource localDataSource;
  final NotificationService notificationService;

  UsageRepositoryImpl({
    required this.localDataSource,
    required this.notificationService,
  });

  @override
  Future<List<AppUsageEntity>> getDailyUsageStats() async {
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
