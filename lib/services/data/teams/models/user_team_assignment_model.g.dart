// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_team_assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTeamAssignmentModel _$UserTeamAssignmentModelFromJson(
        Map<String, dynamic> json) =>
    UserTeamAssignmentModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      teamId: json['team_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserTeamAssignmentModelToJson(
        UserTeamAssignmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'team_id': instance.teamId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
