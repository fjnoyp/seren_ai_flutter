import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

/// Base class for all notification data
abstract class NotificationData {
  final String type;

  const NotificationData({required this.type});

  Map<String, String> toJson();

  /// Factory to create the appropriate notification data from raw data
  static NotificationData? fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'task_update' => TaskUpdateNotificationData.fromJson(json),
      'task_assignment' => TaskAssignmentNotificationData.fromJson(json),
      'task_comment' => TaskCommentNotificationData.fromJson(json),
      'task_reminder' => TaskReminderNotificationData.fromJson(json),
      _ => null,
    };
  }
}

/// Base class for all task notification data
abstract class TaskNotificationData extends NotificationData {
  final String taskId;

  const TaskNotificationData({
    required this.taskId,
    required super.type,
  });
}

/// Data for task update notifications
class TaskUpdateNotificationData extends TaskNotificationData {
  final TaskFieldEnum updateType;

  const TaskUpdateNotificationData({
    required super.taskId,
    required this.updateType,
  }) : super(type: 'task_update');

  @override
  Map<String, String> toJson() => {
        'type': type,
        'task_id': taskId,
        'update_type': updateType.name,
      };

  factory TaskUpdateNotificationData.fromJson(Map<String, dynamic> json) {
    return TaskUpdateNotificationData(
      taskId: json['task_id'] as String,
      updateType: TaskFieldEnum.values.byName(json['update_type'] as String),
    );
  }
}

/// Data for task assignment notifications
class TaskAssignmentNotificationData extends TaskNotificationData {
  final bool isAssignment;

  const TaskAssignmentNotificationData({
    required super.taskId,
    required this.isAssignment,
  }) : super(type: 'task_assignment');

  @override
  Map<String, String> toJson() => {
        'type': type,
        'task_id': taskId,
        'is_assignment': isAssignment.toString(),
      };

  factory TaskAssignmentNotificationData.fromJson(Map<String, dynamic> json) {
    return TaskAssignmentNotificationData(
      taskId: json['task_id'] as String,
      isAssignment: (json['is_assignment'] as String).toLowerCase() == 'true',
    );
  }
}

/// Data for task comment notifications
class TaskCommentNotificationData extends TaskNotificationData {
  const TaskCommentNotificationData({
    required super.taskId,
  }) : super(type: 'task_comment');

  @override
  Map<String, String> toJson() => {
        'type': type,
        'task_id': taskId,
      };

  factory TaskCommentNotificationData.fromJson(Map<String, dynamic> json) {
    return TaskCommentNotificationData(
      taskId: json['task_id'] as String,
    );
  }
}

/// Data for task reminder notifications
class TaskReminderNotificationData extends TaskNotificationData {
  const TaskReminderNotificationData({
    required super.taskId,
  }) : super(type: 'task_reminder');

  @override
  Map<String, String> toJson() => {
        'type': type,
        'task_id': taskId,
      };

  factory TaskReminderNotificationData.fromJson(Map<String, dynamic> json) {
    return TaskReminderNotificationData(
      taskId: json['task_id'] as String,
    );
  }
}
