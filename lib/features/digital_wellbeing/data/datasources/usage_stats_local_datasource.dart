// lib/features/digital_wellbeing/data/datasources/usage_stats_local_datasource.dart

import 'package:focus_wellbeing_app/core/database/sqlite_database.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';

abstract class UsageStatsLocalDataSource {
  Future<List<UsageLimit>> getUsageLimits();
  Future<void> saveOrUpdateLimit({
    required String packageName,
    required String appName,
    required int limitMinutes,
    bool? isBlocked,
  });
}

class UsageStatsLocalDataSourceImpl implements UsageStatsLocalDataSource {
  final SqliteDatabase database;

  UsageStatsLocalDataSourceImpl(this.database);

  @override
  Future<List<UsageLimit>> getUsageLimits() async {
    return database.getUsageLimits();
  }

  @override
  Future<void> saveOrUpdateLimit({
    required String packageName,
    required String appName,
    required int limitMinutes,
    bool? isBlocked,
  }) async {
    final existingRecord = await database.findUsageLimit(packageName);
    final record = existingRecord ?? UsageLimit()
      ..packageName = packageName
      ..appName = appName
      ..dailyLimitMinutes = limitMinutes
      ..currentUsageMinutes = 0
      ..isBlocked = false
      ..lastUpdated = DateTime.now();

    record.appName = appName;
    record.dailyLimitMinutes = limitMinutes;
    if (isBlocked != null) {
      record.isBlocked = isBlocked;
    }
    record.lastUpdated = DateTime.now();
    await database.saveUsageLimit(record);
  }
}
