import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';

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

class ProjectListTile extends StatelessWidget {
  final ProjectModel project;

  const ProjectListTile({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(project.name),
      subtitle: Text(
          project.description ?? AppLocalizations.of(context)!.noDescription),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO p3: Navigate to project details page
      },
    );
  }
}
