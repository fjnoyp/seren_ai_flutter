import 'package:flutter/widgets.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/models/task_budget_item_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  totalValueWithBdi,
  weight;

  String toHumanReadable(BuildContext context) => switch (this) {
        BudgetItemFieldEnum.itemNumber =>
          AppLocalizations.of(context)?.itemNumber ?? '',
        BudgetItemFieldEnum.type =>
          AppLocalizations.of(context)?.type ?? 'Tipo',
        BudgetItemFieldEnum.code =>
          AppLocalizations.of(context)?.code ?? 'Código',
        BudgetItemFieldEnum.source =>
          AppLocalizations.of(context)?.source ?? 'Fonte',
        BudgetItemFieldEnum.name =>
          AppLocalizations.of(context)?.description ?? 'Descrição',
        BudgetItemFieldEnum.amount =>
          AppLocalizations.of(context)?.amount ?? 'Qtd',
        BudgetItemFieldEnum.measureUnit =>
          AppLocalizations.of(context)?.measureUnit ?? 'Un',
        BudgetItemFieldEnum.unitValue =>
          AppLocalizations.of(context)?.unitValue ?? 'Valor Un',
        BudgetItemFieldEnum.unitValueWithBdi =>
          AppLocalizations.of(context)?.unitValueWithBdi ?? 'Valor Un com BDI',
        BudgetItemFieldEnum.totalValue =>
          AppLocalizations.of(context)?.totalValue ?? 'Valor Total',
        BudgetItemFieldEnum.totalValueWithBdi =>
          AppLocalizations.of(context)?.totalValueWithBdi ?? 'Total com BDI',
        BudgetItemFieldEnum.weight =>
          AppLocalizations.of(context)?.weightPercentage ?? 'Peso (%)',
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
        BudgetItemFieldEnum.totalValueWithBdi ||
        BudgetItemFieldEnum.weight =>
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
        BudgetItemFieldEnum.weight => null, // use totalValue instead
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
        BudgetItemFieldEnum.weight => null, // use totalValue instead
      };
}
