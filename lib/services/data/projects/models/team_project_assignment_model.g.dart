// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_project_assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamProjectAssignmentModel _$TeamProjectAssignmentModelFromJson(
        Map<String, dynamic> json) =>
    TeamProjectAssignmentModel(
      id: json['id'] as String?,
      teamId: json['teamId'] as String,
      projectId: json['projectId'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TeamProjectAssignmentModelToJson(
        TeamProjectAssignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'projectId': instance.projectId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
