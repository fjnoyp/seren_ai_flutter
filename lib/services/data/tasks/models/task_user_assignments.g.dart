// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_user_assignments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskUserAssignments _$TaskUserAssignmentsFromJson(Map<String, dynamic> json) =>
    TaskUserAssignments(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$TaskUserAssignmentsToJson(
        TaskUserAssignments instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'user_id': instance.userId,
    };
