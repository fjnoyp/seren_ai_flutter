// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_project_assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProjectAssignmentModel _$UserProjectAssignmentModelFromJson(
        Map<String, dynamic> json) =>
    UserProjectAssignmentModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserProjectAssignmentModelToJson(
        UserProjectAssignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'project_id': instance.projectId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
