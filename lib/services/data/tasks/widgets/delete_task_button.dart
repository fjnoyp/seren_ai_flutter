import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/tasks_db_provider.dart';

class DeleteTaskButton extends ConsumerWidget {
  final String taskId;

  const DeleteTaskButton({Key? key, required this.taskId}) : super(key: key);

// TODO p2: delete is not working - the item disappears then immediately reappears. If internet is lost delete works ... suggesting powersync is successfully deleting from the local cache, but that supabase is rejecting or not receiving the delete, causing powersync to immediately reload that item. Powersync sync rules could be misconfigured, ie. the issue likely exists in the supabase and/or powersync repos. If the issue is here, it would be related to the powersync init code. 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () async {
        final tasksDb = ref.watch(tasksDbProvider);
        await tasksDb.deleteItem(taskId);
      },
    );
  }
}
