import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      valueToString: (date) => _valueToString(date, context: context),
      enabled: enabled,
      value: dueDate?.toLocal(),
      showSelectionModal: (BuildContext context) async {
        await pickAndUpdateDueDate(ref, context);
      },
    );
  }

  String _valueToString(DateTime? date, {required BuildContext context}) {
    final dayFormat =
        DateFormat.yMMMd(AppLocalizations.of(context)!.localeName).add_jm();
    return date == null
        ? AppLocalizations.of(context)!.chooseDueDate
        : dayFormat.format(date);
  }

  String? _validator(DateTime? date) {
    // return date == null ? 'Due date is required' : null;
  }
}
