import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_selected_task_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_filter_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/inline_creation/cur_inline_creating_task_id_provider.dart';

class InlineTaskCreationButton extends HookConsumerWidget {
  const InlineTaskCreationButton({
    super.key,
    this.isPhase = false,
    this.initialParentTaskId,
    this.initialStatus,
    this.onPressed,
  });

  final bool isPhase;
  final String? initialParentTaskId;
  final StatusEnum? initialStatus;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        // Disable sort so that when the task is created,
        // it stays where it was created at to avoid confusion
        ref.read(taskFilterStateProvider.notifier).updateSortOption(null);
        ref.read(curInlineCreatingTaskIdProvider.notifier).state = await ref
            .read(curSelectedTaskIdNotifierProvider.notifier)
            .createNewTask(
              isPhase: isPhase,
              initialParentTaskId: initialParentTaskId,
              initialStatus: initialStatus,
            );
        onPressed?.call();
      },
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
