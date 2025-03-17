// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrgModel _$OrgModelFromJson(Map<String, dynamic> json) => OrgModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isEnabled: json['is_enabled'] == null
          ? true
          : OrgModel._boolFromJson(json['is_enabled']),
    );

Map<String, dynamic> _$OrgModelToJson(OrgModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_enabled': OrgModel._boolToJson(instance.isEnabled),
    };
