enum TaskPriority { low, medium, high, urgent }

enum TreeStatus { growing, completed, withered }

enum SyncStatus { pending, synced, error }

class UserTask {
  int id = 0;
  late String uuid;
  late String title;
  String? description;
  late TaskPriority priority;
  late int estimatedPomodoros;
  late int completedPomodoros;
  DateTime? dueDate;
  bool isCompleted = false;
  String? calendarEventId;
  late DateTime createdAt;
  late DateTime updatedAt;
}

class PomodoroSession {
  int id = 0;
  late String uuid;
  late String taskId;
  late int durationMinutes;
  late DateTime startTime;
  DateTime? endTime;
  bool isSuccessful = false;
  int fatigueRating = 1;
  late SyncStatus calendarSyncStatus;
}

class PlantTree {
  int id = 0;
  late String uuid;
  late String species;
  late TreeStatus status;
  late DateTime plantedAt;
  late int growthDurationMinutes;
  String? associatedPomodoroSessionId;
}

class DailyForestStats {
  final int treesPlanted;
  final int focusMinutes;

  const DailyForestStats({
    required this.treesPlanted,
    required this.focusMinutes,
  });
}

class CalendarEvent {
  int id = 0;
  late String googleEventId;
  late String title;
  String? description;
  late DateTime startTime;
  late DateTime endTime;
  bool isAutoScheduled = false;
  String? aiReasoning;
}

class UsageLimit {
  int id = 0;
  late String packageName;
  late String appName;
  late int dailyLimitMinutes;
  late int currentUsageMinutes;
  bool isBlocked = false;
  late DateTime lastUpdated;
}
