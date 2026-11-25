import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_wellbeing_app/core/database/sqlite_database.dart';
import 'package:focus_wellbeing_app/core/security/encryption_service.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SqliteDatabase Persistencia Cifrada', () {
    late Directory tempDir;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      tempDir = Directory.systemTemp.createTempSync('focus_wellbeing_db_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'persiste sesiones, árboles y límites al cerrar y reabrir con la misma clave',
      () async {
        final encryptionService = EncryptionService();
        final db1 = await SqliteDatabase.open(
          encryptionService: encryptionService,
          directoryPath: tempDir.path,
        );

        final now = DateTime.now();
        final session = PomodoroSession()
          ..uuid = 'sess-001'
          ..taskId = 'task-001'
          ..durationMinutes = 25
          ..startTime = now.subtract(const Duration(minutes: 25))
          ..endTime = now
          ..isSuccessful = true
          ..fatigueRating = 2
          ..calendarSyncStatus = SyncStatus.pending;

        final tree = PlantTree()
          ..uuid = 'tree-001'
          ..species = 'Roble Nobilis'
          ..status = TreeStatus.completed
          ..plantedAt = now
          ..growthDurationMinutes = 25
          ..associatedPomodoroSessionId = session.uuid;

        await db1.saveSessionAndPlantTree(session: session, tree: tree);

        final limit = UsageLimit()
          ..packageName = 'com.instagram.android'
          ..appName = 'Instagram'
          ..dailyLimitMinutes = 30
          ..currentUsageMinutes = 15
          ..isBlocked = false
          ..lastUpdated = now;
        await db1.saveUsageLimit(limit);

        await db1.close();

        // Reabrir la base simulando reinicio de la aplicación con la misma clave.
        final db2 = await SqliteDatabase.open(
          encryptionService: encryptionService,
          directoryPath: tempDir.path,
        );

        final stats = await db2.getDailyForestStats();
        final trees = await db2.getPlantTrees();
        final limits = await db2.getUsageLimits();

        expect(stats.treesPlanted, equals(1));
        expect(stats.focusMinutes, equals(25));
        expect(trees.length, equals(1));
        expect(trees.first.species, equals('Roble Nobilis'));
        expect(limits.length, equals(1));
        expect(limits.first.packageName, equals('com.instagram.android'));
        expect(limits.first.dailyLimitMinutes, equals(30));

        await db2.close();
        expect(File(p.join(tempDir.path, sqliteDatabaseName)).existsSync(),
            isTrue);
      },
    );
  });
}
