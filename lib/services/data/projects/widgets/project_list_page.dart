import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';

class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUserRole = ref.read(curUserOrgRoleProvider).value;

    return Column(
      children: [
        Expanded(
          child: AsyncValueHandlerWidget(
            value: ref.watch(curUserViewableProjectsProvider),
            data: (projects) => projects.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.noProjectsFound))
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectListTile(project: project);
                    },
                  ),
          ),
        ),
        if (curUserRole == OrgRole.admin || curUserRole == OrgRole.editor)
          CreateItemBottomButton(
            onPressed: () => openCreateProjectPage(ref, context),
            buttonText: AppLocalizations.of(context)!.createProject,
          ),
      ],
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
      onTap: () => openProjectPage(ref, context, projectId: project.id),
    );
  }
}
