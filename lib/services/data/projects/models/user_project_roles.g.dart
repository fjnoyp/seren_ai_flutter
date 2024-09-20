// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_project_roles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProjectRoles _$UserProjectRolesFromJson(Map<String, dynamic> json) =>
    UserProjectRoles(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      projectId: json['projectId'] as String,
      projectRole: json['projectRole'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserProjectRolesToJson(UserProjectRoles instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'projectRole': instance.projectRole,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
