import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/status_view.dart';

class BaseStatusSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<StatusEnum?> statusProvider;
  final Function(WidgetRef, StatusEnum?) updateStatus;
  final bool showLabelWidget; // show/hide the labelWidget

  const BaseStatusSelectionField({
    super.key,
    required this.enabled,
    required this.statusProvider,
    required this.updateStatus,
    this.showLabelWidget = true, // Default to true
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskStatus = ref.watch(statusProvider);

    return AnimatedModalSelectionField<StatusEnum>(
      labelWidget: showLabelWidget == true
          ? const Icon(Icons.flag)
          : const SizedBox.shrink(), // Show/hide based on the nullable boolean
      validator: (status) =>
          null, // status == null ? 'Status is required' : null,
      valueToString: (status) =>
          status?.toHumanReadable(context) ??
          AppLocalizations.of(context)!.selectStatus,
      valueToWidget: (status) => StatusView(
        status: status,
        outline:
            showLabelWidget, // current implementation will outline when showLabelWidget is true
      ),
      enabled: enabled,
      value: curTaskStatus,
      options: StatusEnum.values,
      onValueChanged: (ref, status) {
        updateStatus(ref, status);
      },
    );
  }
}
