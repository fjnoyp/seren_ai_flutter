// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_team_role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTeamRoleModel _$UserTeamRoleModelFromJson(Map<String, dynamic> json) =>
    UserTeamRoleModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      teamId: json['team_id'] as String,
      teamRole: json['team_role'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserTeamRoleModelToJson(UserTeamRoleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'team_id': instance.teamId,
      'team_role': instance.teamRole,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
