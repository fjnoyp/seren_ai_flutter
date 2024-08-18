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
    );

Map<String, dynamic> _$UserProjectRolesToJson(UserProjectRoles instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'projectRole': instance.projectRole,
    };
