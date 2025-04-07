// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_budget_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskBudgetItemModel _$TaskBudgetItemModelFromJson(Map<String, dynamic> json) =>
    TaskBudgetItemModel(
      id: json['id'] as String?,
      parentTaskId: json['parent_task_id'] as String,
      budgetItemRefId: json['budget_item_ref_id'] as String?,
      itemNumber: (json['item_number'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      unitValue: (json['unit_value'] as num).toDouble(),
    );

Map<String, dynamic> _$TaskBudgetItemModelToJson(
        TaskBudgetItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_task_id': instance.parentTaskId,
      'budget_item_ref_id': instance.budgetItemRefId,
      'item_number': instance.itemNumber,
      'amount': instance.amount,
      'unit_value': instance.unitValue,
    };
