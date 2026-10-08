// lib/features/digital_wellbeing/domain/usecases/set_app_limit_usecase.dart

import '../repositories/usage_repository.dart';

class SetAppLimitUseCase {
  final UsageRepository repository;

  SetAppLimitUseCase(this.repository);

  Future<void> call(
      String packageName, String appName, int limitMinutes) async {
    await repository.setAppUsageLimit(packageName, appName, limitMinutes);
  }
}
