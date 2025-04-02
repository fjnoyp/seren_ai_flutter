import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/models/budget_item_ref_model.dart';
import 'package:seren_ai_flutter/services/data/budget/repositories/budget_queries.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/common/base_repository.dart';

final budgetItemRefsRepositoryProvider =
    Provider<BudgetItemReferencesRepository>((ref) {
  return BudgetItemReferencesRepository(ref.watch(dbProvider), ref);
});

class BudgetItemReferencesRepository
    extends BaseRepository<BudgetItemRefModel> {
  final Ref ref;

  const BudgetItemReferencesRepository(super.db, this.ref,
      {super.primaryTable = 'budget_item_references'});

  @override
  BudgetItemRefModel fromJson(Map<String, dynamic> json) {
    return BudgetItemRefModel.fromJson(json);
  }

  Stream<List<BudgetItemRefModel>> watchBudgetItems({
    required String orgId,
  }) {
    return watch(
      BudgetQueries.getOrgBudgetItemsQuery,
      {
        'org_id': orgId,
      },
    );
  }

  Future<List<BudgetItemRefModel>> getBudgetItems({
    required String orgId,
  }) async {
    return get(
      BudgetQueries.getOrgBudgetItemsQuery,
      {
        'org_id': orgId,
      },
    );
  }

  Stream<BudgetItemRefModel> watchBudgetItemById({
    required String budgetItemId,
  }) {
    return watchById(budgetItemId);
  }

  Future<BudgetItemRefModel?> getBudgetItemById({
    required String budgetItemId,
  }) async {
    return getById(budgetItemId);
  }

  Future<void> updateBudgetItemRefField({
    required String budgetItemId,
    required BudgetItemFieldEnum field,
    required String value,
  }) async {
    print('updateBudgetItemRefField: $budgetItemId, $field, $value');

    await updateField(budgetItemId, field.toDbField(), value);
  }
}
