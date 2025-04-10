import 'package:flutter/widgets.dart';
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
}
