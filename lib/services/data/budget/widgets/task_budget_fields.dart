import 'package:seren_ai_flutter/services/data/budget/providers/cur_org_available_budget_items.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_items_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/task_budget_items_repository.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_budget_text_field.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';

/// Item Number Field
class TaskBudgetItemNumberField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetItemNumberField({
    super.key,
    required this.budgetItemId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: taskBudgetItemByIdProvider(budgetItemId)
              .select((value) => value.value?.itemNumber.toString() ?? ''),
          updateValue: (ref, value) => ref
              .read(taskBudgetItemsRepositoryProvider)
              .updateTaskBudgetItemField(
                budgetItemId: budgetItemId,
                field: BudgetItemFieldEnum.itemNumber,
                value: value,
              ),
          numbersOnly: true,
        );
}

/// Type Field
class TaskBudgetTypeField extends BaseBudgetTextField {
  final String? budgetItemRefId;

  TaskBudgetTypeField({
    super.key,
    required this.budgetItemRefId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemRefId)
              .select((value) => value.value?.type ?? ''),
          updateValue: (ref, value) async {
            if (budgetItemRefId != null) {
              await ref
                  .read(budgetItemRefsRepositoryProvider)
                  .updateBudgetItemRefField(
                    budgetItemId: budgetItemRefId,
                    field: BudgetItemFieldEnum.type,
                    value: value,
                  );
            }
          },
        );
}

/// Name Field
class TaskBudgetNameField extends BaseBudgetAutosuggestionTextField {
  final String budgetItemId;
  final String? budgetItemRefId;

  TaskBudgetNameField({
    super.key,
    required this.budgetItemId,
    required this.budgetItemRefId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemRefId)
              .select((value) => value.value?.name ?? ''),
          updateFieldValue: (ref, value) async {
            if (budgetItemRefId != null) {
              await ref
                  .read(budgetItemRefsRepositoryProvider)
                  .updateBudgetItemRefField(
                    budgetItemId: budgetItemRefId,
                    field: BudgetItemFieldEnum.name,
                    value: value,
                  );
            } else {
              final newBudgetItemRefId = await ref
                  .read(taskBudgetItemsServiceProvider)
                  .createBudgetItemRef(name: value);
              await ref
                  .read(taskBudgetItemsRepositoryProvider)
                  .updateTaskBudgetItemReference(
                    budgetItemId: budgetItemId,
                    budgetItemRefId: newBudgetItemRefId,
                  );
            }
          },
          updateBudgetItemRefId: (ref, value) async {
            await ref
                .read(taskBudgetItemsRepositoryProvider)
                .updateTaskBudgetItemReference(
                  budgetItemId: budgetItemId,
                  budgetItemRefId: value,
                );
          },
          fieldToSearch: BudgetItemFieldEnum.name,
        );
}

/// Code Field
class TaskBudgetCodeField extends BaseBudgetAutosuggestionTextField {
  final String budgetItemId;
  final String? budgetItemRefId;

  TaskBudgetCodeField({
    super.key,
    required this.budgetItemId,
    required this.budgetItemRefId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemRefId)
              .select((value) => value.value?.code ?? ''),
          updateFieldValue: (ref, value) async {
            if (budgetItemRefId != null) {
              await ref
                  .read(budgetItemRefsRepositoryProvider)
                  .updateBudgetItemRefField(
                    budgetItemId: budgetItemRefId,
                    field: BudgetItemFieldEnum.code,
                    value: value,
                  );
            } else {
              final newBudgetItemRefId = await ref
                  .read(taskBudgetItemsServiceProvider)
                  .createBudgetItemRef(code: value);
              await ref
                  .read(taskBudgetItemsRepositoryProvider)
                  .updateTaskBudgetItemReference(
                    budgetItemId: budgetItemId,
                    budgetItemRefId: newBudgetItemRefId,
                  );
            }
          },
          updateBudgetItemRefId: (ref, value) async {
            await ref
                .read(taskBudgetItemsRepositoryProvider)
                .updateTaskBudgetItemReference(
                  budgetItemId: budgetItemId,
                  budgetItemRefId: value,
                );
          },
          fieldToSearch: BudgetItemFieldEnum.code,
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
          valueProvider: taskBudgetItemByIdProvider(budgetItemId)
              .select((value) => value.value?.amount.toString() ?? ''),
          updateValue: (ref, value) => ref
              .read(taskBudgetItemsRepositoryProvider)
              .updateTaskBudgetItemField(
                budgetItemId: budgetItemId,
                field: BudgetItemFieldEnum.amount,
                value: value,
              ),
          numbersOnly: true,
        );
}

/// Measure Unit Field
class TaskBudgetMeasureUnitField extends BaseBudgetTextField {
  final String? budgetItemRefId;

  TaskBudgetMeasureUnitField({
    super.key,
    required this.budgetItemRefId,
    required bool isEnabled,
  }) : super(
          isEditable: isEnabled,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemRefId)
              .select((value) => value.value?.measureUnit ?? ''),
          updateValue: (ref, value) async {
            if (budgetItemRefId != null) {
              await ref
                  .read(budgetItemRefsRepositoryProvider)
                  .updateBudgetItemRefField(
                    budgetItemId: budgetItemRefId,
                    field: BudgetItemFieldEnum.measureUnit,
                    value: value,
                  );
            }
          },
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
          updateValue: (ref, value) => ref
              .read(taskBudgetItemsRepositoryProvider)
              .updateTaskBudgetItemField(
                budgetItemId: budgetItemId,
                field: BudgetItemFieldEnum.unitValue,
                value: value,
              ),
          numbersOnly: true,
          formatAsCurrency: true,
        );
}
