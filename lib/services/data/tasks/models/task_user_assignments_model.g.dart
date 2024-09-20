// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_user_assignments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskUserAssignmentsModel _$TaskUserAssignmentsModelFromJson(
        Map<String, dynamic> json) =>
    TaskUserAssignmentsModel(
      id: json['id'] as String?,
      taskId: json['task_id'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TaskUserAssignmentsModelToJson(
        TaskUserAssignmentsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
