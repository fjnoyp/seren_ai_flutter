

import 'package:seren_ai_flutter/services/data/common/widgets/form/base_description_selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';

class TaskDescriptionSelectionField extends BaseDescriptionSelectionField {
 TaskDescriptionSelectionField({
    super.key,
    required super.enabled,
  }) : super(
          descriptionProvider: curTaskProvider.select((state) => state.task.description),
          updateDescription: (ref, description) => 
              ref.read(curTaskProvider.notifier).updateTask(
                ref.read(curTaskProvider).task.copyWith(description: description)
              ),
        );
}
