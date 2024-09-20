import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/color_animation.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/ui_constants.dart';


// TODO p1 : add proper time selection for due date
// WARNING - beware of utc / local time issues in storage !!! 
// I think it should be okay since we convert to ISO string at the end - but be careful 
class TaskDueDateSelectionField extends ConsumerWidget {
  final bool enabled;

  const TaskDueDateSelectionField({
    Key? key,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskDueDate = ref.watch(curTaskDueDateProvider);

    // TODO p4: color ignored due to animation 
    //final defaultColor = getDueDateColor(curTaskDueDate);

    return 
    AnimatedSelectionField<DateTime>(
      labelWidget: const Icon(Icons.date_range),
      validator: _validator,
      valueToString: _valueToString,
      enabled: enabled,
      value: curTaskDueDate,
      //defaultColor: defaultColor,
      //options: [], // No options needed for date selection
      showSelectionModal: (BuildContext context,
          void Function(WidgetRef, DateTime)? onValueChanged3) async {
        await ref.read(curTaskProvider.notifier).pickAndUpdateDueDate(context);
      },
      onValueChanged3: (ref, date) async {
        //await ref.read(curTaskProvider.notifier).updateDueDate(date);
      },
    );
  }

  String _valueToString(DateTime? date) {
    return date == null ? 'Choose a Due Date' : date.toString();
  }

  String? _validator(DateTime? date) {
    return date == null ? 'Due date is required' : null;
  }
}
