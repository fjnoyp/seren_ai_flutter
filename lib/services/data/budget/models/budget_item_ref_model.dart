import 'package:json_annotation/json_annotation.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/common/uuid.dart';

part 'budget_item_ref_model.g.dart';

/// This model represents a budget item reference.
/// It is used to represent a budget item reference from the source tables
/// (e.g. SINAPI, SICRO, SETOP, etc. or own org sources)
/// with reusable reference values like item name, measure unit, etc.
///
/// These references are used to populate the budget item fields in the task budget,
/// and they're in a separate table to avoid duplicating the same reference values
/// for the same item across different tasks.
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

  /// Factory constructor to be used before the user selects an item reference
  factory BudgetItemRefModel.empty() => BudgetItemRefModel(
        type: '',
        code: '',
        source: '',
        name: '',
        measureUnit: '',
        baseUnitValue: 0,
      );

  BudgetItemRefModel copyWith({
    String? id,
    String? parentOrgId,
    String? type,
    String? code,
    String? source,
    String? name,
    String? measureUnit,
    double? baseUnitValue,
  }) =>
      BudgetItemRefModel(
        id: id ?? this.id,
        parentOrgId: parentOrgId ?? this.parentOrgId,
        type: type ?? this.type,
        code: code ?? this.code,
        source: source ?? this.source,
        name: name ?? this.name,
        measureUnit: measureUnit ?? this.measureUnit,
        baseUnitValue: baseUnitValue ?? this.baseUnitValue,
      );

  factory BudgetItemRefModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetItemRefModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BudgetItemRefModelToJson(this);
}
