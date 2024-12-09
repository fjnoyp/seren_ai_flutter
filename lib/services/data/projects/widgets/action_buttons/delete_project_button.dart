import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/projects/projects_db_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_project_state_provider.dart';

class DeleteProjectButton extends ConsumerWidget {
  const DeleteProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final itemName = ref.read(curProjectStateProvider).project.name;
        await showDialog(
          context: context,
          builder: (context) => DeleteConfirmationDialog(
            itemName: itemName,
            onDelete: () {
              final projectsDb = ref.watch(projectsDbProvider);
              projectsDb
                  .deleteItem(ref.read(curProjectStateProvider).project.id)
                  .then((_) => Navigator.of(context).maybePop());
            },
          ),
        );
      },
    );
  }
}
