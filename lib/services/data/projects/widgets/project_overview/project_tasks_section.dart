import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_board_view.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_filters.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_overview/sub_lists/project_tasks_sectioned_list_view.dart';
import 'package:seren_ai_flutter/services/data/tasks/filtered/task_search_modal.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/gantt_task_page.dart';

enum ProjectTasksSectionViewMode {
  list,
  board,
  gantt,
}

class ProjectTasksSection extends StatelessWidget {
  const ProjectTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isLargeScreen = constraints.maxWidth > 800;
      return isLargeScreen
          ? const ProjectTasksSectionWeb(ProjectTasksSectionViewMode.board)
          : const ProjectTasksSectionMobile();
    });
  }
}

class ProjectTasksSectionWeb extends HookConsumerWidget {
  const ProjectTasksSectionWeb(this.viewMode, {super.key});

  final ProjectTasksSectionViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curProjectId = ref.watch(curSelectedProjectIdNotifierProvider);
    if (curProjectId == null && viewMode == ProjectTasksSectionViewMode.gantt) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ProjectTasksFilters(
            onShowCustomDateRangePicker: _showCustomDateRangePicker,
            useHorizontalScroll: false,
          ),
        ),
        Expanded(
          child: switch (viewMode) {
            ProjectTasksSectionViewMode.list =>
              const ProjectTasksSectionedListView(),
            ProjectTasksSectionViewMode.board => const ProjectTasksBoardView(),
            ProjectTasksSectionViewMode.gantt =>
              GanttChart(projectId: curProjectId),
          },
        ),
      ],
    );
  }

  Future<DateTimeRange?> _showCustomDateRangePicker(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 360,
          height: 480,
          child: DateRangePickerDialog(
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
          ),
        ),
      ),
    );
  }
}

class ProjectTasksSectionMobile extends StatelessWidget {
  const ProjectTasksSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => showTaskSearchModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.search),
                  const Spacer(),
                  const BaseAiAssistantButton(size: 30),
                ],
              ),
            ),
          ),
        ),
        const Expanded(
          child: ProjectTasksSectionedListView(),
        ),
      ],
    );
  }
}
