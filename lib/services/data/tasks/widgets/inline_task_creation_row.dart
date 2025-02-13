import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';

class InlineTaskCreationWidget extends HookConsumerWidget {
  const InlineTaskCreationWidget({
    super.key,
    required this.additionalFields,
    this.isPhase = false,
    this.initialParentTaskId,
    this.initialStatus,
  });

  /// Additional fields to show in the inline task creation row,
  /// besides the name field.
  final List<TaskFieldEnum> additionalFields;
  final bool isPhase;
  final String? initialParentTaskId;
  final StatusEnum? initialStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = useState(false);
    final newTaskId = ref.watch(curInlineCreatingTaskIdProvider);

    if (newTaskId == null) isEditing.value = false;

    return isEditing.value
        ? TapRegion(
            onTapOutside: (value) {
              ref.read(curInlineCreatingTaskIdProvider.notifier).state = null;
            },
            child: ListTile(
              title: TaskNameField(
                taskId: newTaskId!,
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...additionalFields
                        .where((field) => field != TaskFieldEnum.name)
                        .map(
                          (field) => Flexible(
                            child: TaskSelectionField(
                              field,
                              taskId: newTaskId,
                              showLabelWidget: false,
                            ),
                          ),
                        ),
                    DeleteTaskButton(newTaskId),
                  ],
                ),
              ),
            ),
          )
        : TextButton.icon(
            onPressed: () async {
              ref.read(curInlineCreatingTaskIdProvider.notifier).state =
                  await ref
                      .read(curSelectedTaskIdNotifierProvider.notifier)
                      .createNewTask(
                        updateState: false,
                        initialParentTaskId: initialParentTaskId,
                        initialStatus: initialStatus,
                      );
              isEditing.value = true;
            },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.createTask),
          );
  }
}

final curInlineCreatingTaskIdProvider = StateProvider<String?>((ref) => null);
