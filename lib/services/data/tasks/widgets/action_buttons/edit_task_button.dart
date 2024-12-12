import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_page.dart';

class EditTaskButton extends ConsumerWidget {
  const EditTaskButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // remove self from stack
        Navigator.pop(context);
        openTaskPage(context, ref, mode: EditablePageMode.edit);
      },
    );
  }
}
