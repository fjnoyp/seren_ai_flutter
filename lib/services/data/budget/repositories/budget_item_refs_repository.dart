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

  Future<void> updateBudgetItemRefField({
    required String budgetItemId,
    required BudgetItemFieldEnum field,
    required String value,
  }) async {
    await updateField(budgetItemId, field.toDbField(), value);
  }

  // base unit value isn't a BudgetItemFieldEnum field - and doesn't need to be
  Future<void> updateBudgetItemRefBaseUnitValue({
    required String budgetItemId,
    required double newBaseUnitValue,
  }) async {
    await updateField(budgetItemId, 'base_unit_value', newBaseUnitValue);
  }
}
