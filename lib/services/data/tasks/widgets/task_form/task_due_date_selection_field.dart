import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/selection_field.dart';

class TaskDueDateSelectionField extends ConsumerWidget {
  final bool enabled;

  const TaskDueDateSelectionField({
    Key? key,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskDueDate = ref.watch(curTaskDueDateProvider);

    return Row(
      children: [
        const Icon(Icons.date_range),
        const SizedBox(width: 8),
        Expanded(
          child: TextButton(
            onPressed: enabled
                ? () async {
                    await ref
                        .read(curTaskProvider.notifier)
                        .pickAndUpdateDueDate(context);
                  }
                : null,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 10),
            ),
            child: Text(
              _valueToString(curTaskDueDate),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: enabled ? null : Colors.grey[600],
                    backgroundColor: enabled ? null : Colors.grey[200],
                  ),
            ),
          ),
        ),
      ],
    );
  }

  String _valueToString(DateTime? date) {
    return date == null ? 'Choose a Due Date' : date.toString();
  }

  String? _validator(DateTime? date) {
    return date == null ? 'Due date is required' : null;
  }
}
