// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_org_role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOrgRoleModel _$UserOrgRoleModelFromJson(Map<String, dynamic> json) =>
    UserOrgRoleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orgId: json['org_id'] as String,
      orgRole: json['org_role'] as String,
    );

Map<String, dynamic> _$UserOrgRoleModelToJson(UserOrgRoleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'org_id': instance.orgId,
      'org_role': instance.orgRole,
    };
