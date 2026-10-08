// lib/features/digital_wellbeing/data/datasources/usage_stats_local_datasource.dart

import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:isar/isar.dart';

abstract class UsageStatsLocalDataSource {
  Future<List<UsageLimit>> getUsageLimits();
  Future<void> saveOrUpdateLimit({
    required String packageName,
    required String appName,
    required int limitMinutes,
  });
}

class UsageStatsLocalDataSourceImpl implements UsageStatsLocalDataSource {
  final Isar isar;

  UsageStatsLocalDataSourceImpl(this.isar);

  @override
  Future<List<UsageLimit>> getUsageLimits() async {
    // Consulta todos los registros de límites guardados en la base de datos cifrada
    return await isar.usageLimits.where().findAll();
  }

  @override
  Future<void> saveOrUpdateLimit({
    required String packageName,
    required String appName,
    required int limitMinutes,
  }) async {
    await isar.writeTxn(() async {
      // Buscar si ya existe una configuración para esta aplicación por su packageName
      final existingRecord = await isar.usageLimits
          .filter()
          .packageNameEqualTo(packageName)
          .findFirst();

      if (existingRecord != null) {
        existingRecord.dailyLimitMinutes = limitMinutes;
        existingRecord.lastUpdated = DateTime.now();
        await isar.usageLimits.put(existingRecord);
      } else {
        final newRecord = UsageLimit()
          ..packageName = packageName
          ..appName = appName
          ..dailyLimitMinutes = limitMinutes
          ..currentUsageMinutes = 0
          ..isBlocked = false
          ..lastUpdated = DateTime.now();
        await isar.usageLimits.put(newRecord);
      }
    });
  }
}
