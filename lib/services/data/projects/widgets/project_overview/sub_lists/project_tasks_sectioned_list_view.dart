import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_context_helper/widgets/ai_context_view.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/create_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_filter_view_type.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/tasks_filtered_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_item_view.dart';

class ProjectTasksSectionedListView extends ConsumerWidget {
  const ProjectTasksSectionedListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

    final tasks = ref.watch(tasksByProjectFilteredProvider(
        (projectId, TaskFilterViewType.projectOverview)));

    final showProjectIndicator =
        CurSelectedProjectIdNotifier.isEverythingId(projectId);

    return SingleChildScrollView(
      child: Column(children: [
        tasks.isNotEmpty
            ? AIContextTaskList(tasks: tasks)
            : const SizedBox.shrink(),
        CreateTaskButton(
          initialProjectId: projectId,
          initialStatus: StatusEnum.open,
        ),
        ...[StatusEnum.open, StatusEnum.inProgress, StatusEnum.finished].map(
          (status) {
            final filteredTasks =
                tasks.where((task) => task.status == status).toList();

            return Card(
              child: ExpansionTile(
                initiallyExpanded: filteredTasks.isNotEmpty,
                title: Text(
                  '${status.toHumanReadable(context)} (${filteredTasks.length})',
                ),
                expandedAlignment: Alignment.centerLeft,
                shape: const Border(),
                childrenPadding: const EdgeInsets.only(bottom: 24),
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) => TaskListItemView(
                      filteredTasks[index],
                      showProjectIndicator: showProjectIndicator,
                    ),
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                  ),
                  const Divider(height: 1),
                  CreateTaskButton(
                    initialProjectId: projectId,
                    initialStatus: status,
                  ),
                  // ListTile(
                  //   title: InlineTaskCreationButton(
                  //     initialStatus: status,
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }
}
