import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/selected_project_service_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteProjectButton extends ConsumerWidget {
  const DeleteProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.deleteProjectTooltip,
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final itemName =
            ref.read(selectedProjectServiceProvider).value!.project.name;
        await showDialog(
          context: context,
          builder: (context) => DeleteConfirmationDialog(
            itemName: itemName,
            onDelete: () {
              final projectsDb = ref.watch(projectsDbProvider);
              projectsDb
                  .deleteItem(ref
                      .read(selectedProjectServiceProvider)
                      .value!
                      .project
                      .id)
                  .then((_) => ref.read(navigationServiceProvider).pop());
              ref.invalidate(selectedProjectServiceProvider);
              if (isWebVersion) {
                ref.read(navigationServiceProvider).navigateToAndRemoveUntil(
                    AppRoutes.home.name, (_) => false);
              }
            },
          ),
        );
      },
    );
  }
}
