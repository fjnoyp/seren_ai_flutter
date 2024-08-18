// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      statusEnum: $enumDecodeNullable(_$StatusEnumEnumMap, json['status_enum']),
      priorityEnum:
          $enumDecodeNullable(_$PriorityEnumEnumMap, json['priority_enum']),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      createdDate: DateTime.parse(json['created_date'] as String),
      lastUpdatedDate: DateTime.parse(json['last_updated_date'] as String),
      authorUserId: json['author_user_id'] as String,
      parentTeamId: json['parent_team_id'] as String?,
      parentProjectId: json['parent_project_id'] as String,
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status_enum': _$StatusEnumEnumMap[instance.statusEnum],
      'priority_enum': _$PriorityEnumEnumMap[instance.priorityEnum],
      'due_date': instance.dueDate?.toIso8601String(),
      'created_date': instance.createdDate.toIso8601String(),
      'last_updated_date': instance.lastUpdatedDate.toIso8601String(),
      'author_user_id': instance.authorUserId,
      'parent_team_id': instance.parentTeamId,
      'parent_project_id': instance.parentProjectId,
      'estimated_duration_minutes': instance.estimatedDurationMinutes,
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
