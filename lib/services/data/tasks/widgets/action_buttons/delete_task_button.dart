import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

class DeleteTaskButton extends ConsumerWidget {
  const DeleteTaskButton(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final itemName =
            ref.watch(taskStreamProvider(taskId)).value?.name ?? '';
        await showDialog(
          context: context,
          builder: (context) {
            return DeleteConfirmationDialog(
              itemName: itemName,
              onDelete: () {
                final tasksRepository = ref.read(tasksRepositoryProvider);
                tasksRepository
                    .deleteItem(taskId)
                    .then((_) => Navigator.of(context).maybePop());
              },
            );
          },
        );
      },
    );
  }
}
