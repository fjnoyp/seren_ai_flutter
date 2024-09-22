import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseDueDateSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<DateTime?> dueDateProvider;
  final Function(WidgetRef, BuildContext) pickAndUpdateDueDate;

  const BaseDueDateSelectionField({
    super.key,
    required this.enabled,
    required this.dueDateProvider,
    required this.pickAndUpdateDueDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDate = ref.watch(dueDateProvider);

    return AnimatedSelectionField<DateTime>(
      labelWidget: const Icon(Icons.date_range),
      validator: _validator,
      valueToString: _valueToString,
      enabled: enabled,
      value: dueDate?.toLocal(),
      showSelectionModal: (BuildContext context) async {
        await pickAndUpdateDueDate(ref, context);
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