import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BaseDueDateSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<DateTime?> dueDateProvider;
  final Function(WidgetRef, DateTime) updateDueDate;

  const BaseDueDateSelectionField({
    super.key,
    required this.enabled,
    required this.dueDateProvider,
    required this.updateDueDate,
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
        return _pickDueDate(context, initialDate: dueDate ?? DateTime.now())
            .then(
          (pickedDateTime) => pickedDateTime != null
              ? updateDueDate(ref, pickedDateTime)
              : null,
        );
      },
    );
  }

  Future<DateTime?> _pickDueDate(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate.toLocal()),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        ).toUtc();
      }
    }

    return null;
  }

  String _valueToString(DateTime? date, {required BuildContext context}) {
    final dayFormat =
        DateFormat.yMMMd(AppLocalizations.of(context)!.localeName).add_jm();
    return date == null
        ? AppLocalizations.of(context)!.chooseDueDate
        : dayFormat.format(date);
  }

  String? _validator(DateTime? date) {
    return null;
  
    // return date == null ? 'Due date is required' : null;
  }
}
