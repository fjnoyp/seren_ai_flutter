// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_team_assignments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskTeamAssignments _$TaskTeamAssignmentsFromJson(Map<String, dynamic> json) =>
    TaskTeamAssignments(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      teamId: json['team_id'] as String,
    );

Map<String, dynamic> _$TaskTeamAssignmentsToJson(
        TaskTeamAssignments instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'team_id': instance.teamId,
    };
