import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';

class DeleteTaskButton extends ConsumerWidget {
  final String taskId;

  const DeleteTaskButton({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      // TODO: show a confirmation dialog before deleting
      onPressed: () async {
        final tasksDb = ref.watch(tasksDbProvider);
        tasksDb
            .deleteItem(taskId)
            .then((_) => Navigator.of(context).maybePop());
      },
    );
  }
}
