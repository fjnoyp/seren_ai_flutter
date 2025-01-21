import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseMinuteSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<int?> durationProvider;
  final Function(WidgetRef, int?) updateDuration;
  final Widget Function(WidgetRef) labelWidgetBuilder;
  final String nullValueString;
  final String nullOptionString;

  const BaseMinuteSelectionField({
    super.key,
    required this.enabled,
    required this.durationProvider,
    required this.updateDuration,
    required this.labelWidgetBuilder,
    required this.nullValueString,
    required this.nullOptionString,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDuration = ref.watch(durationProvider);

    return AnimatedModalMinuteSelectionField(
      nullValueString: nullValueString,
      nullOptionString: nullOptionString,
      labelWidget: labelWidgetBuilder(ref),
      validator: (duration) => null,
      enabled: enabled,
      value: curDuration,
      quickOptions: const [120, 60, 30, 15],
      onValueChanged: (ref, value) {
        updateDuration(ref, value);
      },
    );
  }
}
