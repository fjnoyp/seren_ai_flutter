import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteTaskButton extends ConsumerWidget {
  const DeleteTaskButton(
    this.taskId, {
    super.key,
    this.showLabelText = false,
    this.colored = false,
    this.onDelete,
  });

  final String taskId;
  final bool showLabelText;
  final bool colored;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redColor = Theme.of(context).colorScheme.error;

    return showLabelText
        ? OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: redColor,
              iconColor: redColor,
            ),
            label: Text(AppLocalizations.of(context)!.deleteTask),
            icon: const Icon(Icons.delete),
            onPressed: () async => await _showDeleteConfirmationDialog(
              context,
              ref,
              onDelete,
            ),
          )
        : IconButton(
            icon: const Icon(Icons.delete_outlined),
            onPressed: () async => await _showDeleteConfirmationDialog(
              context,
              ref,
              onDelete,
            ),
            style: IconButton.styleFrom(
              foregroundColor: colored ? redColor : null,
            ),
          );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    VoidCallback? onDelete,
  ) async {
    final itemName =
        ref.watch(taskByIdStreamProvider(taskId)).value?.name ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          itemName: itemName,
          onDelete: () {
            final tasksRepository = ref.read(tasksRepositoryProvider);
            // TODO p1: externalize this to prevent pop when using inline task creation
            ref.read(navigationServiceProvider).pop();
            tasksRepository.deleteItem(taskId);
            onDelete?.call();
          },
        );
      },
    );
  }
}
