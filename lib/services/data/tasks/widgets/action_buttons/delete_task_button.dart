import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_editing_task_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

class DeleteTaskButton extends ConsumerWidget {
  const DeleteTaskButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final itemName =
            ref.read(curEditingTaskStateProvider).value!.taskModel.name;
        await showDialog(
          context: context,
          builder: (context) => DeleteConfirmationDialog(
            itemName: itemName,
            onDelete: () {
              final tasksRepository = ref.watch(tasksRepositoryProvider);
              tasksRepository
                  .deleteItem(
                      ref.read(curEditingTaskStateProvider).value!.taskModel.id)
                  .then((_) => Navigator.of(context).maybePop());
            },
          ),
        );
      },
    );
  }
}
