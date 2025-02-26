// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$StatusEnumEnumMap, json['status']),
      priority: $enumDecodeNullable(_$PriorityEnumEnumMap, json['priority']),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      authorUserId: json['author_user_id'] as String,
      parentProjectId: json['parent_project_id'] as String,
      estimatedDurationMinutes:
          TaskModel._durationFromJson(json['estimated_duration_minutes']),
      reminderOffsetMinutes: (json['reminder_offset_minutes'] as num?)?.toInt(),
      startDateTime: json['start_date_time'] == null
          ? null
          : DateTime.parse(json['start_date_time'] as String),
      parentTaskId: json['parent_task_id'] as String?,
      blockedByTaskId: json['blocked_by_task_id'] as String?,
      type:
          $enumDecodeNullable(_$TaskTypeEnumMap, json['type']) ?? TaskType.task,
      parentOrgId: json['parent_org_id'] as String,
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': _$StatusEnumEnumMap[instance.status],
      'priority': _$PriorityEnumEnumMap[instance.priority],
      'due_date': instance.dueDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'author_user_id': instance.authorUserId,
      'parent_project_id': instance.parentProjectId,
      'estimated_duration_minutes':
          TaskModel._durationToJson(instance.estimatedDurationMinutes),
      'reminder_offset_minutes': instance.reminderOffsetMinutes,
      'start_date_time': instance.startDateTime?.toIso8601String(),
      'parent_task_id': instance.parentTaskId,
      'blocked_by_task_id': instance.blockedByTaskId,
      'type': _$TaskTypeEnumMap[instance.type]!,
      'parent_org_id': instance.parentOrgId,
    };

const _$StatusEnumEnumMap = {
  StatusEnum.cancelled: 'cancelled',
  StatusEnum.open: 'open',
  StatusEnum.inProgress: 'inProgress',
  StatusEnum.finished: 'finished',
  StatusEnum.archived: 'archived',
};

const _$PriorityEnumEnumMap = {
  PriorityEnum.veryLow: 'veryLow',
  PriorityEnum.low: 'low',
  PriorityEnum.normal: 'normal',
  PriorityEnum.high: 'high',
  PriorityEnum.veryHigh: 'veryHigh',
};

const _$TaskTypeEnumMap = {
  TaskType.phase: 'phase',
  TaskType.task: 'task',
};
