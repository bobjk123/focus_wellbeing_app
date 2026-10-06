// lib/features/shared/data/models/app_entities.dart

import 'package:isar/isar.dart';

part 'app_entities.g.dart';

enum TaskPriority { low, medium, high, urgent }

enum TreeStatus { growing, completed, withered }

enum SyncStatus { pending, synced, error }

/// Entidad para la gestión de tareas (Focus To-Do)
@collection
class UserTask {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  late String title;
  String? description;

  @enumerated
  late TaskPriority priority;

  late int estimatedPomodoros;
  late int completedPomodoros;

  DateTime? dueDate;
  bool isCompleted = false;

  String? calendarEventId; // Referencia a Google Calendar

  @Index()
  late DateTime createdAt;
  late DateTime updatedAt;
}

/// Entidad para el registro de sesiones de enfoque Pomodoro
@collection
class PomodoroSession {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  late String taskId;
  late int durationMinutes;
  late DateTime startTime;
  DateTime? endTime;

  bool isSuccessful = false;

  // Métrica para la recomendación ética de IA (Higiene Cognitiva)
  int fatigueRating = 1; // 1 (Energizado) a 5 (Agotado)

  @enumerated
  late SyncStatus calendarSyncStatus;
}

/// Entidad para el árbol virtual (Gamificación Estilo Forest)
@collection
class PlantTree {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String uuid;

  late String species; // ej. 'Oak', 'Pine', 'Bonsai'

  @enumerated
  late TreeStatus status;

  late DateTime plantedAt;
  late int growthDurationMinutes;

  String? associatedPomodoroSessionId;
}

/// Entidad para la integración local con Google Calendar
@collection
class CalendarEvent {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String googleEventId;

  late String title;
  String? description;

  @Index()
  late DateTime startTime;

  @Index()
  late DateTime endTime;

  bool isAutoScheduled = false; // Creado por la IA de Time-Blocking
  String? aiReasoning; // Explainable AI (XAI) justification
}

/// Entidad para el control de tiempo de pantalla (Bienestar Digital)
@collection
class UsageLimit {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String packageName; // ej. 'com.instagram.android'

  late String appName;
  late int dailyLimitMinutes;
  late int currentUsageMinutes;

  bool isBlocked = false;
  late DateTime lastUpdated;
}
