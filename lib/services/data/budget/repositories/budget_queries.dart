class BudgetQueries {
  /// Params:
  /// - org_id: String
  ///
  /// Get all budget items for a given organization id
  static const String getOrgBudgetItemsQuery = '''
  SELECT * FROM budget_item_references
  WHERE parent_org_id = :org_id
  OR parent_org_id IS NULL
  ''';

  /// Params:
  /// - task_id: String
  ///
  /// Get all task budgets for a given task id
  static const String getTaskBudgetsQuery = '''
  SELECT * FROM task_budget_items
  WHERE parent_task_id = :task_id
  ORDER BY item_number
  ''';
}
