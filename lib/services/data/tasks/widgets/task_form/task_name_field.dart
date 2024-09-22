import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_name_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';

class TaskNameField extends BaseNameField {
  TaskNameField({
    super.key,
    required super.enabled,
  }) : super(
          nameProvider: curTaskProvider.select((state) => state.task.name),
          updateName: (ref, name) => 
              ref.read(curTaskProvider.notifier).updateTaskName(name),
        );
}
