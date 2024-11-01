import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(curUserProjectsListenerProvider);

    return projects == null
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noProjectsFound))
              : ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectListTile(project: project);
                  },
                );
  }
}

class ProjectListTile extends StatelessWidget {
  final ProjectModel project;

  const ProjectListTile({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(project.name),
      subtitle: Text(project.description ?? AppLocalizations.of(context)!.noDescription),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO p3: Navigate to project details page
      },
    );
  }
}
