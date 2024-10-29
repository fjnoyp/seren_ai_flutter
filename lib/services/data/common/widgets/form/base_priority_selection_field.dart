import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

class BasePrioritySelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<PriorityEnum?> priorityProvider;
  final Function(WidgetRef, PriorityEnum?) updatePriority;

  const BasePrioritySelectionField({
    super.key,
    required this.enabled,
    required this.priorityProvider,
    required this.updatePriority,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskPriority = ref.watch(priorityProvider);

    return AnimatedModalSelectionField<PriorityEnum>(
      labelWidget: const Icon(Icons.priority_high),
      validator: (priority) => null, // priority == null ? 'Priority is required' : null,
      valueToString: (priority) =>
          priority?.toString().enumToHumanReadable ?? 'Select Priority',
      enabled: enabled,
      value: curTaskPriority,
      options: PriorityEnum.values,
      onValueChanged: (ref, priority) {
        updatePriority(ref, priority);
      },
    );
  }
}