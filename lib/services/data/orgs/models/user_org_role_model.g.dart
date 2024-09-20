// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_org_role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOrgRoleModel _$UserOrgRoleModelFromJson(Map<String, dynamic> json) =>
    UserOrgRoleModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      orgId: json['org_id'] as String,
      orgRole: json['org_role'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserOrgRoleModelToJson(UserOrgRoleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'org_id': instance.orgId,
      'org_role': instance.orgRole,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
