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
  /// - task_id: String
  ///
  /// Get the total value of all task budgets for a given task id
  /// If the task is a phase, it will get the total value of all child tasks
  static const String getTaskBudgetTotalValueQuery = '''
  SELECT SUM(amount * unit_value) as total_value FROM task_budget_items 
  WHERE parent_task_id = :task_id
  OR (
    SELECT type FROM tasks WHERE id = :task_id
  ) = 'phase' AND parent_task_id IN (
    SELECT id FROM tasks WHERE parent_task_id = :task_id
  )
  ''';

  /// Params:
  /// - project_id: String
  ///
  /// Get the total value of all project budgets for a given project id
  static const String getProjectBudgetTotalValueQuery = '''
  SELECT SUM(amount * unit_value) as total_value FROM task_budget_items 
  WHERE parent_task_id IN (
    SELECT id FROM tasks WHERE parent_project_id = :project_id AND type = 'task'
  )
  ''';
}
