import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseReminderSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<int?> reminderProvider;
  final Function(WidgetRef, int?) updateReminder;

  const BaseReminderSelectionField({
    super.key,
    required this.enabled,
    required this.reminderProvider,
    required this.updateReminder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskReminder = ref.watch(reminderProvider);

    return AnimatedModalReminderTimeSelectionField(
      labelWidget: curTaskReminder == null
          ? const Icon(Icons.notifications_off)
          : const Icon(Icons.notifications),
      validator: (reminder) => null,
      enabled: enabled,
      value: curTaskReminder,
      quickOptions: const [120, 60, 30, 15],
      onValueChanged: (ref, value) {
        updateReminder(ref, value);
      },
    );
  }
}
