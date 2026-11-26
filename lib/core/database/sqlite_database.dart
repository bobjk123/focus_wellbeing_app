import 'dart:convert';

import 'package:focus_wellbeing_app/core/security/encryption_service.dart';
import 'package:focus_wellbeing_app/features/shared/data/models/app_entities.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

const String sqliteDatabaseName = 'wellbeing.db';

/// SQLCipher-backed database shared by mobile and desktop platforms.
class SqliteDatabase {
  SqliteDatabase._(this._database);

  final Database _database;

  static Future<SqliteDatabase> open({
    EncryptionService? encryptionService,
    String? directoryPath,
  }) async {
    final basePath =
        directoryPath ?? (await getApplicationDocumentsDirectory()).path;
    final key = await (encryptionService ?? EncryptionService())
        .getOrCreateEncryptionKey();
    final database = sqlite3.open(join(basePath, sqliteDatabaseName));
    final password = base64Encode(key);

    // The key is base64, so it cannot contain SQL string delimiters.
    database.execute("PRAGMA key = '$password'");
    database.execute('PRAGMA cipher_compatibility = 4');
    database.execute('PRAGMA foreign_keys = ON');

    final sqlDatabase = SqliteDatabase._(database);
    sqlDatabase._createSchema();
    return sqlDatabase;
  }

  Database get database => _database;

  Future<List<UsageLimit>> getUsageLimits() async {
    final rows = _database.select('SELECT * FROM usage_limits');
    return rows.map(_usageLimitFromRow).toList();
  }

  Future<UsageLimit?> findUsageLimit(String packageName) async {
    final rows = _database.select(
      'SELECT * FROM usage_limits WHERE package_name = ? LIMIT 1',
      [packageName],
    );
    return rows.isEmpty ? null : _usageLimitFromRow(rows.first);
  }

  Future<void> saveUsageLimit(UsageLimit limit) async {
    _database.execute(
      '''
      INSERT INTO usage_limits (
        id, package_name, app_name, daily_limit_minutes,
        current_usage_minutes, is_blocked, last_updated
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(package_name) DO UPDATE SET
        app_name = excluded.app_name,
        daily_limit_minutes = excluded.daily_limit_minutes,
        current_usage_minutes = excluded.current_usage_minutes,
        is_blocked = excluded.is_blocked,
        last_updated = excluded.last_updated
      ''',
      [
        limit.id == 0 ? null : limit.id,
        limit.packageName,
        limit.appName,
        limit.dailyLimitMinutes,
        limit.currentUsageMinutes,
        limit.isBlocked ? 1 : 0,
        limit.lastUpdated.millisecondsSinceEpoch,
      ],
    );
    if (limit.id == 0) {
      limit.id = _database.lastInsertRowId;
    }
  }

  Future<void> saveSessionAndPlantTree({
    required PomodoroSession session,
    required PlantTree tree,
  }) async {
    _database.execute('BEGIN');
    try {
      _database.execute(
        '''
        INSERT INTO pomodoro_sessions (
          id, uuid, task_id, duration_minutes, start_time, end_time,
          is_successful, fatigue_rating, calendar_sync_status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        _pomodoroSessionValues(session),
      );
      session.id = _database.lastInsertRowId;

      _database.execute(
        '''
        INSERT INTO plant_trees (
          id, uuid, species, status, planted_at,
          growth_duration_minutes, associated_pomodoro_session_id
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        _plantTreeValues(tree),
      );
      tree.id = _database.lastInsertRowId;
      _database.execute('COMMIT');
    } catch (_) {
      _database.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<DailyForestStats> getDailyForestStats() async {
    final startOfDay = DateTime.now();
    final dayStart =
        DateTime(startOfDay.year, startOfDay.month, startOfDay.day);
    final rows = _database.select(
      '''
      SELECT COUNT(*) AS tree_count,
             COALESCE(SUM(growth_duration_minutes), 0) AS focus_minutes
      FROM plant_trees
      WHERE status = ? AND planted_at >= ?
      ''',
      [TreeStatus.completed.index, dayStart.millisecondsSinceEpoch],
    );
    final row = rows.single;
    return DailyForestStats(
      treesPlanted: row['tree_count'] as int,
      focusMinutes: row['focus_minutes'] as int,
    );
  }

  Future<List<PlantTree>> getPlantTrees() async {
    final rows = _database.select(
      'SELECT * FROM plant_trees ORDER BY planted_at DESC',
    );
    return rows.map(_plantTreeFromRow).toList();
  }

  /// Devuelve los minutos de enfoque exitosos de lunes a domingo de la semana actual.
  Future<List<int>> getWeeklyFocusMinutes({DateTime? referenceDate}) async {
    final now = referenceDate ?? DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final mondayStart =
        todayStart.subtract(Duration(days: now.weekday - DateTime.monday));
    final nextMondayStart = mondayStart.add(const Duration(days: 7));

    final rows = _database.select(
      '''
      SELECT duration_minutes, start_time
      FROM pomodoro_sessions
      WHERE is_successful = 1
        AND start_time >= ?
        AND start_time < ?
      ''',
      [
        mondayStart.millisecondsSinceEpoch,
        nextMondayStart.millisecondsSinceEpoch,
      ],
    );

    final dailyTotals = List<int>.filled(7, 0);
    for (final row in rows) {
      final startTime =
          DateTime.fromMillisecondsSinceEpoch(row['start_time'] as int);
      final dayIndex = startTime.weekday - DateTime.monday;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyTotals[dayIndex] += row['duration_minutes'] as int;
      }
    }
    return dailyTotals;
  }

  Future<void> close() async => _database.close();

  void _createSchema() {
    _database.execute('''
      CREATE TABLE IF NOT EXISTS user_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL,
        estimated_pomodoros INTEGER NOT NULL,
        completed_pomodoros INTEGER NOT NULL,
        due_date INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        calendar_event_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    _database.execute('''
      CREATE TABLE IF NOT EXISTS pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        task_id TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        is_successful INTEGER NOT NULL DEFAULT 0,
        fatigue_rating INTEGER NOT NULL,
        calendar_sync_status INTEGER NOT NULL
      )
    ''');
    _database.execute('''
      CREATE TABLE IF NOT EXISTS plant_trees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        species TEXT NOT NULL,
        status INTEGER NOT NULL,
        planted_at INTEGER NOT NULL,
        growth_duration_minutes INTEGER NOT NULL,
        associated_pomodoro_session_id TEXT
      )
    ''');
    _database.execute('''
      CREATE TABLE IF NOT EXISTS calendar_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        google_event_id TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        description TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        is_auto_scheduled INTEGER NOT NULL DEFAULT 0,
        ai_reasoning TEXT
      )
    ''');
    _database.execute('''
      CREATE TABLE IF NOT EXISTS usage_limits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_name TEXT NOT NULL UNIQUE,
        app_name TEXT NOT NULL,
        daily_limit_minutes INTEGER NOT NULL,
        current_usage_minutes INTEGER NOT NULL,
        is_blocked INTEGER NOT NULL DEFAULT 0,
        last_updated INTEGER NOT NULL
      )
    ''');
  }

  static PlantTree _plantTreeFromRow(Row row) => PlantTree()
    ..id = row['id'] as int
    ..uuid = row['uuid'] as String
    ..species = row['species'] as String
    ..status = TreeStatus.values[row['status'] as int]
    ..plantedAt = DateTime.fromMillisecondsSinceEpoch(row['planted_at'] as int)
    ..growthDurationMinutes = row['growth_duration_minutes'] as int
    ..associatedPomodoroSessionId =
        row['associated_pomodoro_session_id'] as String?;

  static UsageLimit _usageLimitFromRow(Row row) => UsageLimit()
    ..id = row['id'] as int
    ..packageName = row['package_name'] as String
    ..appName = row['app_name'] as String
    ..dailyLimitMinutes = row['daily_limit_minutes'] as int
    ..currentUsageMinutes = row['current_usage_minutes'] as int
    ..isBlocked = row['is_blocked'] == 1
    ..lastUpdated =
        DateTime.fromMillisecondsSinceEpoch(row['last_updated'] as int);

  static List<Object?> _pomodoroSessionValues(PomodoroSession session) => [
        session.id == 0 ? null : session.id,
        session.uuid,
        session.taskId,
        session.durationMinutes,
        session.startTime.millisecondsSinceEpoch,
        session.endTime?.millisecondsSinceEpoch,
        session.isSuccessful ? 1 : 0,
        session.fatigueRating,
        session.calendarSyncStatus.index,
      ];

  static List<Object?> _plantTreeValues(PlantTree tree) => [
        tree.id == 0 ? null : tree.id,
        tree.uuid,
        tree.species,
        tree.status.index,
        tree.plantedAt.millisecondsSinceEpoch,
        tree.growthDurationMinutes,
        tree.associatedPomodoroSessionId,
      ];
}
