// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_item_ref_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetItemRefModel _$BudgetItemRefModelFromJson(Map<String, dynamic> json) =>
    BudgetItemRefModel(
      id: json['id'] as String?,
      parentOrgId: json['parent_org_id'] as String?,
      type: json['type'] as String,
      code: json['code'] as String,
      source: json['source'] as String,
      name: json['name'] as String,
      measureUnit: json['measure_unit'] as String,
      baseUnitValue: (json['base_unit_value'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetItemRefModelToJson(BudgetItemRefModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_org_id': instance.parentOrgId,
      'type': instance.type,
      'code': instance.code,
      'source': instance.source,
      'name': instance.name,
      'measure_unit': instance.measureUnit,
      'base_unit_value': instance.baseUnitValue,
    };
