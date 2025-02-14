import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_selected_project_providers.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/repositories/projects_repository.dart';

class DeleteProjectButton extends ConsumerWidget {
  const DeleteProjectButton(this.projectId, {super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.deleteProjectTooltip,
      icon: const Icon(Icons.delete),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            final projectName =
                ref.watch(projectByIdStreamProvider(projectId)).value?.name ??
                    '';

            return DeleteConfirmationDialog(
              itemName: projectName,
              onDelete: () async {
                final projectsRepository =
                    ref.watch(projectsRepositoryProvider);
                projectsRepository
                    .deleteItem(projectId)
                    .then((_) => ref.read(navigationServiceProvider).pop());
                if (projectId ==
                    ref.read(curSelectedProjectIdNotifierProvider)!) {
                  ref.invalidate(curSelectedProjectIdNotifierProvider);
                }
                if (isWebVersion) {
                  await ref.read(navigationServiceProvider).pop();
                }
              },
            );
          },
        );
      },
    );
  }
}
