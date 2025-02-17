import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/priority_view.dart';

class BasePrioritySelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<PriorityEnum?> priorityProvider;
  final Function(WidgetRef, PriorityEnum?) updatePriority;
  final bool showLabelWidget; // show/hide the labelWidget

  const BasePrioritySelectionField({
    super.key,
    required this.enabled,
    required this.priorityProvider,
    required this.updatePriority,
    this.showLabelWidget = true, // Default to true
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskPriority = ref.watch(priorityProvider);

    return AnimatedModalSelectionField<PriorityEnum>(
      labelWidget: showLabelWidget == true
          ? const Icon(Icons.priority_high)
          : const SizedBox.shrink(), // Show/hide based on the nullable boolean
      validator: (priority) =>
          null, // priority == null ? 'Priority is required' : null,
      valueToString: (priority) =>
          priority?.toHumanReadable(context) ??
          AppLocalizations.of(context)!.selectPriority,
      valueToWidget: (priority) => PriorityView(
        priority: priority,
        outline:
            showLabelWidget, // current implementation will outline when showLabelWidget is true
      ),
      enabled: enabled,
      value: curTaskPriority,
      options: PriorityEnum.values,
      onValueChanged: (ref, priority) {
        if (priority != curTaskPriority) {
          updatePriority(ref, priority);
        }
      },
    );
  }
}
