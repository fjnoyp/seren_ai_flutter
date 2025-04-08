import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/project_budget_table.dart';
import 'package:seren_ai_flutter/services/data/budget/widgets/share_project_budget_button.dart';

class ProjectBudgetSection extends StatelessWidget {
  const ProjectBudgetSection({super.key, required this.projectId});

  final String projectId;

  static const columns = [
    (
      field: BudgetItemFieldEnum.itemNumber,
      width: 60.0,
    ),
    (
      field: BudgetItemFieldEnum.type,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.code,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.source,
      width: 100.0,
    ),
    (
      field: BudgetItemFieldEnum.name,
      width: 400.0,
    ),
    (
      field: BudgetItemFieldEnum.measureUnit,
      width: 60.0,
    ),
    (
      field: BudgetItemFieldEnum.amount,
      width: 60.0,
    ),
    (
      field: BudgetItemFieldEnum.unitValue,
      width: 80.0,
    ),
    (
      field: BudgetItemFieldEnum.totalValue,
      width: 120.0,
    ),
    (
      field: BudgetItemFieldEnum.totalValueWithBdi,
      width: 120.0,
    ),
    (
      field: BudgetItemFieldEnum.weight,
      width: 80.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // will add month selector here for admeasurements in future
            const Expanded(child: SizedBox.shrink()),
            ShareProjectBudgetButton(projectId: projectId, columns: columns),
          ],
        ),
        Expanded(
          child: ProjectBudgetTable(projectId: projectId, columns: columns),
        ),
      ],
    );
  }
}
