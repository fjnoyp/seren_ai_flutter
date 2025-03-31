import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'budget_item_ref_model.g.dart';

@JsonSerializable()
class BudgetItemRefModel implements IHasId {
  @override
  final String id;

  @JsonKey(name: 'parent_org_id')
  final String? parentOrgId;

  final String type;
  final String code;
  final String source;
  final String name;

  @JsonKey(name: 'measure_unit')
  final String measureUnit;

  @JsonKey(name: 'base_unit_value')
  final double baseUnitValue;

  bool get isOwnSource => source == 'own';

  BudgetItemRefModel({
    String? id,
    this.parentOrgId,
    required this.type,
    required this.code,
    required this.source,
    required this.name,
    required this.measureUnit,
    required this.baseUnitValue,
  }) : id = id ?? uuid.v4();

  /// Factory constructed to be used in loading states
  factory BudgetItemRefModel.empty() => BudgetItemRefModel(
        type: '...',
        code: '...',
        source: '...',
        name: '...',
        measureUnit: '...',
        baseUnitValue: 0,
      );

  factory BudgetItemRefModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetItemRefModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BudgetItemRefModelToJson(this);
}
