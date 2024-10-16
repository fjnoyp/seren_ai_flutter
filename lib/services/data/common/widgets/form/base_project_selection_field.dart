import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/orgs/cur_org/is_cur_user_org_admin_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';

class BaseProjectSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<ProjectModel?> projectProvider;
  final Function(WidgetRef, ProjectModel?) updateProject;

  const BaseProjectSelectionField({
    super.key,
    required this.enabled,
    required this.projectProvider,
    required this.updateProject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCurUserOrgAdmin = ref.watch(isCurUserOrgAdminListenerProvider);
    final selectableProjectsProvider = isCurUserOrgAdmin
        ? curUserViewableProjectsListenerProvider
        : curUserProjectsListenerProvider;
    final curTaskProject = ref.watch(projectProvider);
    final selectableProjects = ref.watch(selectableProjectsProvider);

    return AnimatedModalSelectionField<ProjectModel>(
      labelWidget: const SizedBox(
        width: 60,
        child: Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      validator: (project) => project == null ? 'Project is required' : null,
      valueToString: (project) => project?.name ?? 'Select a Project',
      enabled: enabled,
      value: curTaskProject,
      options: selectableProjects ?? [],
      onValueChanged: (ref, project) {
        updateProject(ref, project);
      },
    );
  }
}
