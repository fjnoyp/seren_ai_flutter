import 'package:seren_ai_flutter/services/data/budget/providers/cur_org_available_budget_items.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budgets_repository.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_budget_text_field.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';

/// Item Number Field
class TaskBudgetItemNumberField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetItemNumberField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
    super.initialValue,
  }) : super(
          isEditable: isEnabled,
          valueProvider: taskBudgetItemByIdProvider(budgetItemId).select(
              (value) => value.value?.itemNumber.toString() ?? ''),
          updateValue: (ref, value) =>
              ref.read(taskBudgetsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.itemNumber,
                    value: value,
                  ),
          numbersOnly: true,
        );
}

/// Type Field
class TaskBudgetTypeField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetTypeField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemId).select(
              (value) => value.value?.type ?? ''),
          updateValue: (ref, value) =>
              ref.read(budgetItemRefsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.type,
                    value: value,
                  ),
        );
}

/// Name Field
class TaskBudgetNameField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetNameField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemId).select(
              (value) => value.value?.name ?? ''),
          updateValue: (ref, value) =>
              ref.read(budgetItemRefsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.name,
                    value: value,
                  ),
        );
}

/// Code Field
class TaskBudgetCodeField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetCodeField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemId).select(
              (value) => value.value?.code ?? ''),  
          updateValue: (ref, value) =>
              ref.read(budgetItemRefsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.code,
                    value: value,
                  ),
        );
}

/// Amount Field
class TaskBudgetAmountField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetAmountField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: taskBudgetItemByIdProvider(budgetItemId).select(
              (value) => value.value?.amount.toString() ?? ''),
          updateValue: (ref, value) =>
              ref.read(taskBudgetsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.amount,
                    value: value,
                  ),
          numbersOnly: true,
        );
}

/// Measure Unit Field
class TaskBudgetMeasureUnitField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetMeasureUnitField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemId).select(
              (value) => value.value?.measureUnit ?? ''),
          updateValue: (ref, value) =>
              ref.read(budgetItemRefsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.measureUnit,
                    value: value,
                  ),
        );
}

/// Unit Value Field
class TaskBudgetUnitValueField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetUnitValueField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: taskBudgetItemByIdProvider(budgetItemId).select(
              (value) => value.value?.unitValue.toStringAsFixed(2) ?? ''),
          updateValue: (ref, value) =>
              ref.read(taskBudgetsRepositoryProvider).updateBudgetItemField(
                    budgetItemId: budgetItemId,
                    field: BudgetItemFieldEnum.unitValue,
                    value: value,
                  ),
          numbersOnly: true,
          formatAsCurrency: true,
        );
}
