import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_selection_options_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_assignees_selection_field.dart';
class TaskAssigneesSelectionField extends BaseAssigneesSelectionField {
  TaskAssigneesSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          assigneesProvider: curTaskAssigneesProvider,
          projectProvider: curTaskProjectProvider,
          updateAssignees: (ref, assignees) =>
              ref.read(curTaskProvider.notifier).updateAssignees(assignees),
          selectableUsersProvider: curTaskSelectionOptionsProvider
              .select((state) => state.selectableUsers),
        );
}