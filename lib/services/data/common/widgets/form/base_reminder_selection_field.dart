import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseMinuteSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<int?> reminderProvider;
  final Function(WidgetRef, int?) updateReminder;
  final Widget Function(WidgetRef) labelWidgetBuilder;

  const BaseMinuteSelectionField({
    super.key,
    required this.enabled,
    required this.reminderProvider,
    required this.updateReminder,
    required this.labelWidgetBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskReminder = ref.watch(reminderProvider);

    return AnimatedModalReminderTimeSelectionField(
      labelWidget: labelWidgetBuilder(ref),
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
