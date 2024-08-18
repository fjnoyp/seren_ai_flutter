// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrgModel _$OrgModelFromJson(Map<String, dynamic> json) => OrgModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$OrgModelToJson(OrgModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
    };
