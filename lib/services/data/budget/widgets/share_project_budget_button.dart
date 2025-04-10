import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/currency_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/budget_item_field_enum.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/share_budget_service_provider.dart';
import 'package:seren_ai_flutter/services/data/budget/providers/task_budget_total_value_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_bdi_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/cur_project_tasks_hierarchy_provider.dart';

class ShareProjectBudgetButton extends ConsumerWidget {
  const ShareProjectBudgetButton({
    super.key,
    required this.projectId,
    required this.columns,
  });

  final String projectId;
  final List<({BudgetItemFieldEnum field, double width})> columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberedTasks = ref.watch(curProjectTasksHierarchyNumberedProvider);
    // We pass the projectTotalValue down here to avoid overcalculations
    final projectTotalValue =
        ref.watch(projectBudgetTotalValueStreamProvider(projectId)).value ??
            0.0;

    if (numberedTasks.isEmpty || projectTotalValue == 0) {
      return const SizedBox.shrink();
    }

    final projectBdi = ref.watch(projectBdiProvider);
    final numberFormat = ref.watch(currencyFormatSNP);

    final MenuController menuController = MenuController();

    return MenuAnchor(
      controller: menuController,
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref.read(shareBudgetServiceProvider).shareBudgetAsPdf(
                  projectId: projectId,
                  numberedTasks: numberedTasks,
                  projectTotalValue: projectTotalValue,
                  columns: columns,
                  projectBdi: projectBdi,
                  currencyFormat: numberFormat,
                );
          },
          child: const Text('PDF'),
        ),
        MenuItemButton(
          onPressed: () {
            ref.read(shareBudgetServiceProvider).shareBudgetAsCsv(
                  projectId: projectId,
                  numberedTasks: numberedTasks,
                  columns: columns.map((c) => c.field).toList(),
                  projectTotalValue: projectTotalValue,
                  projectBdi: projectBdi,
                  currencyFormat: numberFormat,
                );
          },
          child: const Text('CSV'),
        ),
      ],
      builder: (context, controller, child) {
        return FilledButton.icon(
          onPressed: controller.open,
          icon: const Icon(Icons.file_download_outlined),
          label: Text(AppLocalizations.of(context)?.exportAs ?? 'Export as'),
        );
      },
    );
  }
}
