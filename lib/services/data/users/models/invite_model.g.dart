// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteModel _$InviteModelFromJson(Map<String, dynamic> json) => InviteModel(
      id: json['id'] as String?,
      email: json['email'] as String,
      orgId: json['org_id'] as String,
      orgName: json['org_name'] as String,
      orgRole: $enumDecode(_$OrgRoleEnumMap, json['org_role']),
      authorUserId: json['author_user_id'] as String,
      authorUserName: json['author_user_name'] as String,
      status: $enumDecodeNullable(_$InviteStatusEnumMap, json['status']) ??
          InviteStatus.pending,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InviteModelToJson(InviteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'org_id': instance.orgId,
      'org_name': instance.orgName,
      'org_role': _$OrgRoleEnumMap[instance.orgRole]!,
      'author_user_id': instance.authorUserId,
      'author_user_name': instance.authorUserName,
      'status': _$InviteStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$OrgRoleEnumMap = {
  OrgRole.admin: 'admin',
  OrgRole.editor: 'editor',
  OrgRole.member: 'member',
};

const _$InviteStatusEnumMap = {
  InviteStatus.pending: 'pending',
  InviteStatus.accepted: 'accepted',
  InviteStatus.declined: 'declined',
};
