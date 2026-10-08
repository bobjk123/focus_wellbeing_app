// lib/features/digital_wellbeing/domain/usecases/get_usage_stats_usecase.dart

import '../entities/app_usage_entity.dart';
import '../repositories/usage_repository.dart';

class GetUsageStatsUseCase {
  final UsageRepository repository;

  GetUsageStatsUseCase(this.repository);

  Future<List<AppUsageEntity>> call() async {
    return await repository.getDailyUsageStats();
  }
}
