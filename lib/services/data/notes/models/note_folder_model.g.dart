// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_folder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteFolderModel _$NoteFolderModelFromJson(Map<String, dynamic> json) =>
    NoteFolderModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentTeamId: json['parent_team_id'] as String?,
      parentProjectId: json['parent_project_id'] as String,
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NoteFolderModelToJson(NoteFolderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'parent_team_id': instance.parentTeamId,
      'parent_project_id': instance.parentProjectId,
      'estimated_duration_minutes': instance.estimatedDurationMinutes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
