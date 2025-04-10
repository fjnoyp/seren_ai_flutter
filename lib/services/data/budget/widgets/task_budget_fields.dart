import 'package:seren_ai_flutter/services/data/budget/providers/cur_org_available_budget_items_stream_providers.dart';
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
    super.prefix,
    required super.isEnabled,
  }) : super(
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
    required super.isEnabled,
  }) : super(
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

/// Add a new base class for these autosuggestion fields
abstract class TaskBudgetRefAutosuggestionField
    extends BaseBudgetAutosuggestionTextField {
  TaskBudgetRefAutosuggestionField({
    super.key,
    required String budgetItemId,
    required String? budgetItemRefId,
    required super.fieldToSearch,
    required super.isEnabled,
    required super.valueProvider,
  }) : super(
          updateFieldValue: (ref, value) async {
            if (budgetItemRefId != null) {
              await ref
                  .read(budgetItemRefsRepositoryProvider)
                  .updateBudgetItemRefField(
                    budgetItemId: budgetItemRefId,
                    field: fieldToSearch,
                    value: value,
                  );
            } else {
              final newBudgetItemRefId = await ref
                  .read(taskBudgetItemsServiceProvider)
                  .createBudgetItemRef(
                    name: fieldToSearch == BudgetItemFieldEnum.name
                        ? value
                        : null,
                    code: fieldToSearch == BudgetItemFieldEnum.code
                        ? value
                        : null,
                  );
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
        );
}

/// Name field
class TaskBudgetNameField extends TaskBudgetRefAutosuggestionField {
  TaskBudgetNameField({
    super.key,
    required super.budgetItemId,
    required super.budgetItemRefId,
    required super.isEnabled,
  }) : super(
          fieldToSearch: BudgetItemFieldEnum.name,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemRefId)
              .select((value) => value.value?.name ?? ''),
        );
}

/// Code field
class TaskBudgetCodeField extends TaskBudgetRefAutosuggestionField {
  TaskBudgetCodeField({
    super.key,
    required super.budgetItemId,
    required super.budgetItemRefId,
    required super.isEnabled,
  }) : super(
          fieldToSearch: BudgetItemFieldEnum.code,
          valueProvider: budgetItemRefByIdStreamProvider(budgetItemRefId)
              .select((value) => value.value?.code ?? ''),
        );
}

/// Amount Field
class TaskBudgetAmountField extends BaseBudgetTextField {
  final String budgetItemId;

  TaskBudgetAmountField({
    super.key,
    required this.budgetItemId,
    required super.isEnabled,
  }) : super(
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
    required super.isEnabled,
  }) : super(
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
    required super.isEnabled,
  }) : super(
          valueProvider: taskBudgetItemByIdProvider(budgetItemId).select(
              (value) => value.value?.unitValue.toStringAsFixed(2) ?? ''),
          updateValue: (ref, value) async {
            await ref
                .read(taskBudgetItemsRepositoryProvider)
                .updateTaskBudgetItemField(
                  budgetItemId: budgetItemId,
                  field: BudgetItemFieldEnum.unitValue,
                  value: value,
                );
            final budgetItemRefId = await ref
                .read(taskBudgetItemsRepositoryProvider)
                .getById(budgetItemId)
                .then((value) => value?.budgetItemRefId);
            if (budgetItemRefId != null) {
              final baseUnitValue = await ref
                  .read(budgetItemRefsRepositoryProvider)
                  .getById(budgetItemRefId)
                  .then((value) => value?.baseUnitValue);
              if (baseUnitValue == null || baseUnitValue == 0) {
                await ref
                    .read(budgetItemRefsRepositoryProvider)
                    .updateBudgetItemRefBaseUnitValue(
                      budgetItemId: budgetItemRefId,
                      newBaseUnitValue: double.parse(value),
                    );
              }
            }
          },
          numbersOnly: true,
          formatAsCurrency: true,
        );
}
