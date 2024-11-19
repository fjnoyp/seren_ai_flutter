import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';

class DeleteTaskButton extends ConsumerWidget {
  const DeleteTaskButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final itemName = ref.read(curTaskStateProvider).value!.task.name;
        await showDialog(
          context: context,
          builder: (context) => DeleteConfirmationDialog(
            itemName: itemName,
            onDelete: () {
              final tasksDb = ref.watch(tasksDbProvider);
              tasksDb
                  .deleteItem(ref.read(curTaskStateProvider).value!.task.id)
                  .then((_) => Navigator.of(context).maybePop());
            },
          ),
        );
      },
    );
  }
}
