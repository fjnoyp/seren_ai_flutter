import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/tasks_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class ProjectTasksSectionedListView extends ConsumerWidget {
  const ProjectTasksSectionedListView({this.sort, this.filterCondition});

  final Comparator<TaskModel>? sort;
  final bool Function(TaskModel)? filterCondition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

    return AsyncValueHandlerWidget(
      value: ref.watch(tasksByProjectStreamProvider(projectId)),
      data: (tasks) {
        return SingleChildScrollView(
          child: Column(
            children: StatusEnum.values.map(
              (status) {
                final filteredTasks = tasks
                        ?.where((task) =>
                            task.status == status &&
                            (filterCondition == null || filterCondition!(task)))
                        .toList() ??
                    [];

                if (sort != null) {
                  filteredTasks.sort(sort);
                }

                return Card(
                  child: ExpansionTile(
                    initiallyExpanded: filteredTasks.isNotEmpty,
                    title: Text(status.toHumanReadable(context)),
                    expandedAlignment: Alignment.centerLeft,
                    shape: const Border(),
                    childrenPadding: const EdgeInsets.only(bottom: 24),
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) =>
                            TaskListTileItemView(filteredTasks[index]),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        dense: true,
                        onTap: () =>
                            ref.read(taskNavigationServiceProvider).openNewTask(
                                  initialProjectId: projectId,
                                  initialStatus: status,
                                ),
                        leading: const SizedBox.shrink(),
                        title: Text(
                          AppLocalizations.of(context)!.createNewTask,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
