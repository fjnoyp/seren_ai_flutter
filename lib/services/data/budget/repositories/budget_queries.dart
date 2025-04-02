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

  /// Params:
  /// - budget_item_id: String
  ///
  /// Get a task budget for a given budget item id
  static const String getTaskBudgetItemByIdQuery = '''
  SELECT * FROM task_budget_items
  WHERE id = :budget_item_id
  ''';

  /// Params:
  /// - budget_item_id: String
  ///
  /// Get a budget item reference for a given budget item id
  static const String getBudgetItemRefByIdQuery = '''
  SELECT * FROM budget_item_references
  WHERE id = :budget_item_id
  ''';
}
