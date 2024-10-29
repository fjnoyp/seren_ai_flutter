import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseStatusSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<StatusEnum?> statusProvider;
  final Function(WidgetRef, StatusEnum?) updateStatus;

  const BaseStatusSelectionField({
    super.key,
    required this.enabled,
    required this.statusProvider,
    required this.updateStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskStatus = ref.watch(statusProvider);

    return AnimatedModalSelectionField<StatusEnum>(
      labelWidget: const Icon(Icons.flag),
      validator: (status) => null, // status == null ? 'Status is required' : null,
      valueToString: (status) =>
          status?.toString().enumToHumanReadable ?? 'Select Status',
      enabled: enabled,
      value: curTaskStatus,
      options: StatusEnum.values,
      onValueChanged: (ref, status) {
        updateStatus(ref, status);
      },
    );
  }
}