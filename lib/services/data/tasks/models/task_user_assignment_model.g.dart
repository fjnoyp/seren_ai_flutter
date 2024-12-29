// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_user_assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskUserAssignmentModel _$TaskUserAssignmentModelFromJson(
        Map<String, dynamic> json) =>
    TaskUserAssignmentModel(
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

Map<String, dynamic> _$TaskUserAssignmentModelToJson(
        TaskUserAssignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
