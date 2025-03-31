import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'task_budget_item_model.g.dart';

@JsonSerializable()
class TaskBudgetItemModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'parent_task_id')
  final String parentTaskId;

  @JsonKey(name: 'budget_item_ref_id')
  final String budgetItemRefId;

  @JsonKey(name: 'item_number')
  final int itemNumber;

  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'unit_value')
  final double unitValue;

  @JsonKey(name: 'is_estimated', fromJson: _boolFromInt)
  final bool isEstimated;

  static bool _boolFromInt(dynamic value) => value == 1;

  double get totalValue => amount * unitValue;

  TaskBudgetItemModel({
    String? id,
    required this.parentTaskId,
    required this.budgetItemRefId,
    required this.itemNumber,
    required this.amount,
    required this.unitValue,
    required this.isEstimated,
  }) : id = id ?? uuid.v4();

  factory TaskBudgetItemModel.empty() => TaskBudgetItemModel(
        id: '',
        parentTaskId: '',
        budgetItemRefId: '',
        itemNumber: 0,
        amount: 0,
        unitValue: 0,
        isEstimated: false,
      );

  factory TaskBudgetItemModel.fromJson(Map<String, dynamic> json) =>
      _$TaskBudgetItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskBudgetItemModelToJson(this);
}
