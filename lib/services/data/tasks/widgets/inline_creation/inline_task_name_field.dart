import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

class InlineTaskNameField extends HookConsumerWidget {
  const InlineTaskNameField({
    super.key,
    required this.taskId,
    this.isPhase = false,
    this.initialParentTaskId,
    this.initialStatus,
  });

  final String taskId;

  // Parameters for batch creation
  final bool isPhase;
  final String? initialParentTaskId;
  final StatusEnum? initialStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The user can either:
    // - tap outside to finish task creation
    // - press enter key to go to the next task
    // - press esc key to cancel task creation
    return TapRegion(
      onTapOutside: (value) {
        ref.read(curInlineCreatingTaskIdProvider.notifier).state = null;
      },
      child: KeyboardListener(
        focusNode: useFocusNode(),
        onKeyEvent: (event) async {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            ref.read(curInlineCreatingTaskIdProvider.notifier).state = await ref
                .read(curSelectedTaskIdNotifierProvider.notifier)
                .createNewTask(
                  initialParentTaskId: initialParentTaskId,
                  initialStatus: initialStatus,
                  isPhase: isPhase,
                );
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            final curTaskId = ref.read(curInlineCreatingTaskIdProvider);
            if (curTaskId != null) {
              ref.read(curInlineCreatingTaskIdProvider.notifier).state = null;
              ref.read(tasksRepositoryProvider).deleteItem(curTaskId);
            }
          }
        },
        child: TaskNameField(
          focusNode: useFocusNode()..requestFocus(),
          taskId: taskId,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
