import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/core/notifications/notification_service.dart';
import 'package:focus_wellbeing_app/core/wellbeing/system_usage_stats_service.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/data/datasources/usage_stats_local_datasource.dart';
import 'package:focus_wellbeing_app/features/digital_wellbeing/data/repositories/usage_repository_impl.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:mocktail/mocktail.dart';

class MockUsageStatsLocalDataSource extends Mock
    implements UsageStatsLocalDataSource {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSystemUsageStatsService extends Mock
    implements SystemUsageStatsService {}

void main() {
  late MockUsageStatsLocalDataSource mockLocalDataSource;
  late MockNotificationService mockNotificationService;
  late UsageRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockUsageStatsLocalDataSource();
    mockNotificationService = MockNotificationService();
    repository = UsageRepositoryImpl(
      localDataSource: mockLocalDataSource,
      notificationService: mockNotificationService,
    );
  });

  UsageLimit buildLimit({
    int id = 1,
    required int limitMinutes,
    required int usageMinutes,
    bool isBlocked = false,
  }) {
    return UsageLimit()
      ..id = id
      ..packageName = 'com.example.social'
      ..appName = 'SocialApp'
      ..dailyLimitMinutes = limitMinutes
      ..currentUsageMinutes = usageMinutes
      ..isBlocked = isBlocked
      ..lastUpdated = DateTime.now();
  }

  group('UsageRepositoryImpl - Notificaciones de límites', () {
    test('envía notificación y marca bloqueada cuando se supera el límite',
        () async {
      final limit = buildLimit(limitMinutes: 30, usageMinutes: 45);
      when(() => mockLocalDataSource.getUsageLimits())
          .thenAnswer((_) async => [limit]);
      when(() => mockNotificationService.showAppLimitExceededNotification(
            notificationId: 1,
            appName: 'SocialApp',
            limitMinutes: 30,
          )).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveOrUpdateLimit(
            packageName: 'com.example.social',
            appName: 'SocialApp',
            limitMinutes: 30,
            isBlocked: true,
          )).thenAnswer((_) async {});

      final stats = await repository.getDailyUsageStats();

      expect(stats.length, equals(1));
      expect(stats.first.isBlocked, isTrue);
      verify(() => mockNotificationService.showAppLimitExceededNotification(
            notificationId: 1,
            appName: 'SocialApp',
            limitMinutes: 30,
          )).called(1);
      verify(() => mockLocalDataSource.saveOrUpdateLimit(
            packageName: 'com.example.social',
            appName: 'SocialApp',
            limitMinutes: 30,
            isBlocked: true,
          )).called(1);
    });

    test('no envía notificación duplicada si la app ya fue marcada bloqueada',
        () async {
      final limit =
          buildLimit(limitMinutes: 30, usageMinutes: 45, isBlocked: true);
      when(() => mockLocalDataSource.getUsageLimits())
          .thenAnswer((_) async => [limit]);

      final stats = await repository.getDailyUsageStats();

      expect(stats.first.isBlocked, isTrue);
      verifyNever(
          () => mockNotificationService.showAppLimitExceededNotification(
                notificationId: any(named: 'notificationId'),
                appName: any(named: 'appName'),
                limitMinutes: any(named: 'limitMinutes'),
              ));
    });

    test('no envía notificación cuando el uso está por debajo del límite',
        () async {
      final limit = buildLimit(limitMinutes: 60, usageMinutes: 20);
      when(() => mockLocalDataSource.getUsageLimits())
          .thenAnswer((_) async => [limit]);

      final stats = await repository.getDailyUsageStats();

      expect(stats.first.isBlocked, isFalse);
      verifyNever(
          () => mockNotificationService.showAppLimitExceededNotification(
                notificationId: any(named: 'notificationId'),
                appName: any(named: 'appName'),
                limitMinutes: any(named: 'limitMinutes'),
              ));
    });

    test('sincroniza uso real del sistema cuando tiene permiso', () async {
      final mockSystemService = MockSystemUsageStatsService();
      final repoWithSystem = UsageRepositoryImpl(
        localDataSource: mockLocalDataSource,
        notificationService: mockNotificationService,
        systemUsageService: mockSystemService,
      );

      final existingLimit = buildLimit(limitMinutes: 30, usageMinutes: 10);
      when(() => mockSystemService.hasUsagePermission())
          .thenAnswer((_) async => true);
      when(() => mockSystemService.getTodayUsageStats()).thenAnswer(
        (_) async => const [
          SystemAppUsage(
            packageName: 'com.example.social',
            appName: 'SocialApp',
            usageMinutes: 25,
          ),
        ],
      );
      when(() => mockLocalDataSource.getUsageLimits())
          .thenAnswer((_) async => [existingLimit]);
      when(() => mockLocalDataSource.saveOrUpdateLimit(
            packageName: 'com.example.social',
            appName: 'SocialApp',
            limitMinutes: 30,
            currentUsageMinutes: 25,
          )).thenAnswer((_) async {});

      await repoWithSystem.getDailyUsageStats();

      verify(() => mockLocalDataSource.saveOrUpdateLimit(
            packageName: 'com.example.social',
            appName: 'SocialApp',
            limitMinutes: 30,
            currentUsageMinutes: 25,
          )).called(1);
    });
  });
}
