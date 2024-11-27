import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserViewableProjectsProvider),
      data: (projects) => projects.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noProjectsFound))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectListTile(project: project);
              },
            ),
    );
  }
}

class ProjectListTile extends ConsumerWidget {
  final ProjectModel project;

  const ProjectListTile({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(project.name),
      subtitle: Text(
          project.description ?? AppLocalizations.of(context)!.noDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO p3: Navigate to project details page
        if (ref.read(isDebugModeSNP)) {
          ref.read(curProjectStateProvider.notifier).setProject(project);
          ref.read(navigationServiceProvider).navigateTo(AppRoutes.projectDetails.name);
        }
      },
    );
  }
}
