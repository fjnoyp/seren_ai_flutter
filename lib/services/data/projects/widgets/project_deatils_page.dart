import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_editing_project_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/form/project_selection_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/providers/user_in_project_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class ProjectDetailsPage extends HookConsumerWidget {
  final EditablePageMode mode;

  const ProjectDetailsPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch selectedProjectServiceProvider in non-create modes
    if (mode != EditablePageMode.create) {
      final curSelectedProject = ref.watch(curSelectedProjectStreamProvider);
      if (curSelectedProject.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (curSelectedProject.hasError || curSelectedProject.value == null) {
        // Handle project deletion by other users
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Pop the current project page (route or dialog)
          ref.read(navigationServiceProvider).pop();
          // Remove all project details routes (in case of dialog, we'd need to pop again)
          ref.read(navigationServiceProvider).popUntil((route) =>
              !(route.settings.name?.contains(AppRoutes.projectOverview.name) ??
                  false));
        });
        return const SizedBox.shrink();
      }
    }

    final curEditingProjectId =
        ref.watch(curEditingProjectIdNotifierProvider) ?? '';

    final curProject =
        ref.watch(projectByIdStreamProvider(curEditingProjectId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Text(
                  curProject.isReloading
                      ? AppLocalizations.of(context)!.saving
                      : curProject.hasError
                          ? AppLocalizations.of(context)!.errorSaving
                          : AppLocalizations.of(context)!.allChangesSaved,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            ProjectNameField(curEditingProjectId),
            const SizedBox(height: 8),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  ProjectDescriptionSelectionField(
                      curEditingProjectId, context),
                  const Divider(),
                  ProjectAddressField(curEditingProjectId, context),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isWebVersion)
              ProjectAssigneesList(
                  ref.watch(curSelectedProjectIdNotifierProvider) ?? ''),
          ],
        ),
      ),
    );
  }
}

class ProjectInfoHeader extends ConsumerWidget {
  const ProjectInfoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curSelectedProjectStreamProvider),
      data: (project) {
        if (project == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              project.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (project.address != null) Text(project.address!),
            const SizedBox(height: 16, width: double.infinity),
            if (project.description != null) Text(project.description!),
          ],
        );
      },
    );
  }
}

class ProjectAssigneesList extends ConsumerWidget {
  const ProjectAssigneesList(this.projectId, {super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAssignees =
        ref.watch(usersInProjectProvider(projectId)).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.assignees,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          itemCount: projectAssignees.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              leading: UserAvatar(projectAssignees[index]),
              title: Text(
                  '${projectAssignees[index].firstName} ${projectAssignees[index].lastName}'),
            );
          },
        ),
      ],
    );
  }
}
