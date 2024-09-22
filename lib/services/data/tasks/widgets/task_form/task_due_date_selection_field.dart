import 'package:seren_ai_flutter/services/data/common/widgets/form/base_due_date_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';

class TaskDueDateSelectionField extends BaseDueDateSelectionField {
  TaskDueDateSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          dueDateProvider: curTaskDueDateProvider,
          pickAndUpdateDueDate: (ref, context) => 
              ref.read(curTaskProvider.notifier).pickAndUpdateDueDate(context),
        );
}