// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_team_role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTeamRoleModel _$UserTeamRoleModelFromJson(Map<String, dynamic> json) =>
    UserTeamRoleModel(
      id: json['id'] as String,
      userAuthId: json['user_auth_id'] as String,
      teamId: json['team_id'] as String,
      teamRole: json['team_role'] as String,
    );

Map<String, dynamic> _$UserTeamRoleModelToJson(UserTeamRoleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_auth_id': instance.userAuthId,
      'team_id': instance.teamId,
      'team_role': instance.teamRole,
    };
