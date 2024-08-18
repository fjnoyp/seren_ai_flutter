// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentOrgId: json['parent_org_id'] as String,
      parentTeamId: json['parent_team_id'] as String?,
    );

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'parent_org_id': instance.parentOrgId,
      'parent_team_id': instance.parentTeamId,
    };
