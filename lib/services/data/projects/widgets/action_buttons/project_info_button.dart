import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectInfoButton extends ConsumerWidget {
  const ProjectInfoButton(this.projectId, {super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.editProjectTooltip,
      icon: const Icon(Icons.settings),
      onPressed: () => ref
          .read(projectNavigationServiceProvider)
          .openProjectPage(mode: EditablePageMode.edit, projectId: projectId),
    );
  }
}
