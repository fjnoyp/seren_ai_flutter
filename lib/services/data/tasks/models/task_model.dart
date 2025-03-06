import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';

part 'task_model.g.dart';

enum PriorityEnum {
  veryLow,
  low,
  normal,
  high,
  veryHigh;

  String toHumanReadable(BuildContext context) => switch (this) {
        PriorityEnum.veryLow => AppLocalizations.of(context)!.veryLow,
        PriorityEnum.low => AppLocalizations.of(context)!.low,
        PriorityEnum.normal => AppLocalizations.of(context)!.normal,
        PriorityEnum.high => AppLocalizations.of(context)!.high,
        PriorityEnum.veryHigh => AppLocalizations.of(context)!.veryHigh,
      };

  static PriorityEnum tryParse(String? value) {
    if (value == null) return PriorityEnum.normal;
    try {
      // exception case for veryLow, veryHigh
      if (value.toLowerCase() == 'verylow') return PriorityEnum.veryLow;
      if (value.toLowerCase() == 'veryhigh') return PriorityEnum.veryHigh;

      return PriorityEnum.values.byName(value.toLowerCase());
    } catch (_) {
      return PriorityEnum.normal;
    }
  }

  int toInt() => switch (this) {
        PriorityEnum.veryLow => 4,
        PriorityEnum.low => 3,
        PriorityEnum.normal => 2,
        PriorityEnum.high => 1,
        PriorityEnum.veryHigh => 0,
      };
}

enum TaskType {
  phase,
  task;

  String toHumanReadable(BuildContext context) => switch (this) {
        TaskType.task => AppLocalizations.of(context)!.task,
        TaskType.phase => AppLocalizations.of(context)!.phase,
      };
}

@JsonSerializable()
class TaskModel implements IHasId {
  @override
  final String id;
  final String name;
  final String? description;

  @JsonKey(name: 'status')
  final StatusEnum? status;

  @JsonKey(name: 'priority')
  final PriorityEnum? priority;

  @JsonKey(
    name: 'due_date',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime? dueDate;

  @JsonKey(
    name: 'created_at',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime? createdAt;

  @JsonKey(
    name: 'updated_at',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime? updatedAt;

  @JsonKey(name: 'author_user_id')
  final String authorUserId;

  @JsonKey(name: 'parent_project_id')
  final String parentProjectId;

  @JsonKey(
      name: 'estimated_duration_minutes',
      fromJson: _durationFromJson,
      toJson: _durationToJson)
  final int? estimatedDurationMinutes;

  @JsonKey(name: 'reminder_offset_minutes')
  final int? reminderOffsetMinutes;

  @JsonKey(
    name: 'start_date_time',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime? startDateTime;

  @JsonKey(name: 'parent_task_id')
  final String? parentTaskId;

  @JsonKey(name: 'blocked_by_task_id')
  final String? blockedByTaskId;

  @JsonKey(defaultValue: TaskType.task)
  final TaskType type;
  bool get isPhase => type == TaskType.phase;

  Duration? get duration {
    if (startDateTime != null && dueDate != null) {
      return dueDate!.difference(startDateTime!);
    }
    return null;
  }

  static int? _durationFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static dynamic _durationToJson(int? value) => value;

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return null;
  }

  static dynamic _dateTimeToJson(DateTime? value) =>
      value?.toUtc().toIso8601String();

  TaskModel({
    String? id,
    required this.name,
    required this.description,
    required this.status,
    this.priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.authorUserId,
    required this.parentProjectId,
    this.estimatedDurationMinutes,
    this.reminderOffsetMinutes,
    DateTime? startDateTime,
    this.parentTaskId,
    this.blockedByTaskId,
    required this.type,
  })  : id = id ?? uuid.v4(),
        assert(dueDate != null || reminderOffsetMinutes == null),
        // Convert to local time when creating the task
        // to ensure that the task is always displayed in the user's local time
        dueDate = dueDate?.toLocal(),
        createdAt = createdAt?.toLocal(),
        updatedAt = updatedAt?.toLocal(),
        startDateTime = startDateTime?.toLocal();

  TaskModel copyWith({
    String? id,
    String? name,
    String? description,
    StatusEnum? status,
    PriorityEnum? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorUserId,
    String? parentProjectId,
    int? estimatedDurationMinutes,
    int? reminderOffsetMinutes,
    DateTime? startDateTime,
    String? parentTaskId,
    String? blockedByTaskId,
    bool removeReminder = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorUserId: authorUserId ?? this.authorUserId,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      reminderOffsetMinutes: removeReminder
          ? null
          : reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      startDateTime: startDateTime ?? this.startDateTime,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      blockedByTaskId: blockedByTaskId ?? this.blockedByTaskId,
      type: type,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  Map<String, dynamic> toAiReadableMap(
      {ProjectModel? project, UserModel? author, List<UserModel>? assignees}) {
    return {
      'task': {
        'name': name,
        'description': description,
        'status': status,
        'priority': priority,
        'due_date': dueDate?.toIso8601String(),
      },
      'author': author?.email ?? 'Unknown',
      'project': project?.name ?? 'No Project',
      'assignees': assignees?.map((user) => user.email).toList() ?? [],
    };
  }
}

class TaskTypeConverter implements JsonConverter<TaskType, String> {
  const TaskTypeConverter();

  @override
  TaskType fromJson(String json) {
    try {
      return TaskType.values.firstWhere(
        (e) => e.name == json,
        orElse: () => TaskType.task, // Fallback value
      );
    } catch (_) {
      return TaskType.task; // Fallback for any errors
    }
  }

  @override
  String toJson(TaskType type) => type.toString().split('.').last;
}
