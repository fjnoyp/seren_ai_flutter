import 'package:flutter/widgets.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';

enum BudgetItemFieldEnum {
  itemNumber,
  type,
  source,
  code,
  name,
  amount,
  measureUnit,
  unitValue,
  unitValueWithBdi,
  totalValue,
  totalValueWithBdi;

  String toHumanReadable(BuildContext context) => switch (this) {
        BudgetItemFieldEnum.itemNumber => '',
        BudgetItemFieldEnum.type => 'Tipo',
        BudgetItemFieldEnum.code => 'Código',
        BudgetItemFieldEnum.source => 'Fonte',
        BudgetItemFieldEnum.name => 'Descrição',
        BudgetItemFieldEnum.amount => 'Qtd',
        BudgetItemFieldEnum.measureUnit => 'Un',
        BudgetItemFieldEnum.unitValue => 'Valor Un',
        BudgetItemFieldEnum.unitValueWithBdi => 'Valor Un com BDI',
        BudgetItemFieldEnum.totalValue => 'Valor Total',
        BudgetItemFieldEnum.totalValueWithBdi => 'Total com BDI',
      };

  String toDbField() => switch (this) {
        BudgetItemFieldEnum.itemNumber => 'item_number',
        BudgetItemFieldEnum.type => 'type',
        BudgetItemFieldEnum.code => 'code',
        BudgetItemFieldEnum.source => 'source',
        BudgetItemFieldEnum.name => 'name',
        BudgetItemFieldEnum.amount => 'amount',
        BudgetItemFieldEnum.measureUnit => 'measure_unit',
        BudgetItemFieldEnum.unitValue => 'unit_value',

        // The fields below are not in the db
        BudgetItemFieldEnum.unitValueWithBdi ||
        BudgetItemFieldEnum.totalValue ||
        BudgetItemFieldEnum.totalValueWithBdi =>
          '',
      };

  Comparator<BudgetItemRefModel>? get comparatorRefValues => switch (this) {
        BudgetItemFieldEnum.name => (a, b) => a.name.compareTo(b.name),
        BudgetItemFieldEnum.type => (a, b) => a.type.compareTo(b.type),
        BudgetItemFieldEnum.source => (a, b) => a.source.compareTo(b.source),
        BudgetItemFieldEnum.code => (a, b) => a.code.compareTo(b.code),
        BudgetItemFieldEnum.measureUnit => (a, b) =>
            a.measureUnit.compareTo(b.measureUnit),

        // The fields below are not in the ref model
        // use comparatorRealValues instead to compare them
        BudgetItemFieldEnum.itemNumber => null,
        BudgetItemFieldEnum.amount => null,
        BudgetItemFieldEnum.unitValue => null,
        BudgetItemFieldEnum.totalValue => null,
        BudgetItemFieldEnum.unitValueWithBdi => null, // use unitValue instead
        BudgetItemFieldEnum.totalValueWithBdi => null, // use totalValue instead
      };

  Comparator<TaskBudgetItemModel>? get comparatorRealValues => switch (this) {
        BudgetItemFieldEnum.itemNumber => (a, b) =>
            (a.itemNumber.compareTo(b.itemNumber)),
        BudgetItemFieldEnum.amount => (a, b) => (a.amount.compareTo(b.amount)),
        BudgetItemFieldEnum.unitValue => (a, b) =>
            (a.unitValue.compareTo(b.unitValue)),
        BudgetItemFieldEnum.totalValue => (a, b) =>
            a.totalValue.compareTo(b.totalValue),

        // The fields below are in the ref model,
        // use comparatorRefValues instead to compare them
        BudgetItemFieldEnum.name => null,
        BudgetItemFieldEnum.type => null,
        BudgetItemFieldEnum.source => null,
        BudgetItemFieldEnum.code => null,
        BudgetItemFieldEnum.measureUnit => null,
        BudgetItemFieldEnum.unitValueWithBdi => null, // use unitValue instead
        BudgetItemFieldEnum.totalValueWithBdi => null, // use totalValue instead
      };
}
