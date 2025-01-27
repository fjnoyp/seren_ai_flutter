import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';

class EditProjectButton extends ConsumerWidget {
  const EditProjectButton(this.projectId, {super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.editProjectTooltip,
      icon: const Icon(Icons.edit),
      onPressed: () => ref
          .read(projectNavigationServiceProvider)
          .openProjectPage(mode: EditablePageMode.edit, projectId: projectId),
    );
  }
}
