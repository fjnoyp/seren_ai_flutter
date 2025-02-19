import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/form/task_selection_fields.dart';

// class InlineTaskCreationWidget extends HookConsumerWidget {
//   const InlineTaskCreationWidget({
//     super.key,
//     required this.additionalFields,
//     this.isPhase = false,
//     this.initialParentTaskId,
//     this.initialStatus,
//   });

//   /// Additional fields to show in the inline task creation row,
//   /// besides the name field.
//   final List<TaskFieldEnum> additionalFields;
//   final bool isPhase;
//   final String? initialParentTaskId;
//   final StatusEnum? initialStatus;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isEditing = useState(false);
//     final newTaskId = ref.watch(curInlineCreatingTaskIdProvider);
//     final nameFieldFocusNode = useFocusNode();

//     useEffect(() {
//       if (newTaskId != null) {
//         final task = ref.read(taskByIdStreamProvider(newTaskId)).value;
//         if (initialStatus == null) {
//           isEditing.value = true;
//         } else {
//           // Add this to prevent multiple inline widgets from being enabled at the same screen
//           isEditing.value = task?.status == initialStatus;
//         }
//       } else {
//         isEditing.value = false;
//       }
//       return null;
//     }, [ref.watch(curInlineCreatingTaskIdProvider)]);

//     return isEditing.value
//         ? TapRegion(
//             onTapOutside: (value) {
//               ref.read(curInlineCreatingTaskIdProvider.notifier).state = null;
//             },
//             child: ListTile(
//               title: KeyboardListener(
//                 focusNode: useFocusNode(),
//                 onKeyEvent: (event) async {
//                   if (event.logicalKey == LogicalKeyboardKey.enter) {
//                     ref.read(curInlineCreatingTaskIdProvider.notifier).state =
//                         await ref
//                             .read(curSelectedTaskIdNotifierProvider.notifier)
//                             .createNewTask(
//                               initialParentTaskId: initialParentTaskId,
//                               initialStatus: initialStatus,
//                               isPhase: isPhase,
//                             );
//                   }
//                 },
//                 child: TaskNameField(
//                   focusNode: nameFieldFocusNode..requestFocus(),
//                   taskId: newTaskId!,
//                   textStyle: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ),
//               trailing: IntrinsicWidth(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ...additionalFields
//                         .where((field) => field != TaskFieldEnum.name)
//                         .map(
//                           (field) => Flexible(
//                             child: TaskSelectionField(
//                               field,
//                               taskId: newTaskId,
//                               showLabelWidget: false,
//                             ),
//                           ),
//                         ),
//                     DeleteTaskButton(
//                       newTaskId,
//                       colored: true,
//                       onDelete: () {
//                         ref
//                             .read(curInlineCreatingTaskIdProvider.notifier)
//                             .state = null;
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : TextButton.icon(
//             onPressed: () async =>
//                 ref.read(curInlineCreatingTaskIdProvider.notifier).state =
//                     await ref
//                         .read(curSelectedTaskIdNotifierProvider.notifier)
//                         .createNewTask(
//                           initialParentTaskId: initialParentTaskId,
//                           initialStatus: initialStatus,
//                         ),
//             icon: const Icon(Icons.add),
//             label: Text(AppLocalizations.of(context)!.createTask),
//             style: TextButton.styleFrom(
//               alignment: Alignment.centerLeft,
//               foregroundColor: Theme.of(context).colorScheme.outline,
//               iconColor: Theme.of(context).colorScheme.outline,
//             ),
//           );
//   }
// }

class InlineTaskCreationButton extends HookConsumerWidget {
  const InlineTaskCreationButton({
    super.key,
    this.isPhase = false,
    this.initialParentTaskId,
    this.initialStatus,
  });

  final bool isPhase;
  final String? initialParentTaskId;
  final StatusEnum? initialStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async =>
          ref.read(curInlineCreatingTaskIdProvider.notifier).state = await ref
              .read(curSelectedTaskIdNotifierProvider.notifier)
              .createNewTask(
                isPhase: isPhase,
                initialParentTaskId: initialParentTaskId,
                initialStatus: initialStatus,
              ),
      icon: const Icon(Icons.add),
      label: Text(isPhase
          ? AppLocalizations.of(context)!.phase
          : AppLocalizations.of(context)!.task),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        alignment: Alignment.centerLeft,
        foregroundColor: Theme.of(context).colorScheme.outline,
        iconColor: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

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

final curInlineCreatingTaskIdProvider = StateProvider<String?>((ref) => null);
