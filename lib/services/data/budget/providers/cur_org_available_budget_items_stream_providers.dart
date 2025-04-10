import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_item_refs_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';

/// This provider is used to get the available budget items for the current organization.
/// It is used to populate the budget items autofill/autocomplete in the task budget fields.
final curOrgAvailableBudgetItemsStreamProvider =
    StreamProvider<List<BudgetItemRefModel>?>(
  (ref) {
    final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    if (curOrgId == null) throw Exception('No org selected');

    return ref
        .watch(budgetItemRefsRepositoryProvider)
        .watchBudgetItems(orgId: curOrgId);
  },
);

/// Get the budget item reference by id.
final budgetItemRefByIdStreamProvider =
    StreamProvider.family<BudgetItemRefModel, String?>((ref, budgetItemId) {
  if (budgetItemId == null) {
    return Stream.value(BudgetItemRefModel.empty());
  }

  return ref
      .watch(budgetItemRefsRepositoryProvider)
      .watchById(budgetItemId);
});
