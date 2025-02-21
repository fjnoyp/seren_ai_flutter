import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/create_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/inline_task_creation_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_list/task_list_tile_item_view.dart';

class ProjectTasksSectionedListView extends ConsumerWidget {
  const ProjectTasksSectionedListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (projectId == null) return const SizedBox.shrink();

    final tasks = ref.watch(filteredTasksProvider(projectId));

    return SingleChildScrollView(
      child: Column(children: [
        CreateTaskButton(
          initialProjectId: projectId,
          initialStatus: StatusEnum.open,
        ),
        ...StatusEnum.values.map(
          (status) {
            final filteredTasks =
                tasks.where((task) => task.status == status).toList();

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
                    title: InlineTaskCreationButton(
                      initialStatus: status,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }
}
