import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BaseDueDateSelectionField extends _BaseDateTimeSelectionField {
  BaseDueDateSelectionField({
    super.key,
    required super.enabled,
    required ProviderListenable<DateTime?> dueDateProvider,
    required Function(WidgetRef, DateTime) updateDueDate,
  }) : super(
          dateTimeProvider: dueDateProvider,
          updateDateTime: updateDueDate,
          label: ((context) => AppLocalizations.of(context)!.chooseDueDate),
        );
}

class BaseStartDateSelectionField extends _BaseDateTimeSelectionField {
  BaseStartDateSelectionField({
    super.key,
    required super.enabled,
    required ProviderListenable<DateTime?> startDateTimeProvider,
    required Function(WidgetRef, DateTime) updateStartDate,
  }) : super(
          dateTimeProvider: startDateTimeProvider,
          updateDateTime: updateStartDate,
          label: ((context) => AppLocalizations.of(context)!.chooseStartDate),
        );
}

class _BaseDateTimeSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<DateTime?> dateTimeProvider;
  final Function(WidgetRef, DateTime) updateDateTime;
  final String Function(BuildContext) label;

  const _BaseDateTimeSelectionField({
    super.key,
    required this.enabled,
    required this.dateTimeProvider,
    required this.updateDateTime,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDate = ref.watch(dateTimeProvider);

    return AnimatedSelectionField<DateTime>(
      labelWidget: const Icon(Icons.date_range),
      validator: _validator,
      valueToString: (date) => _valueToString(date, context: context),
      enabled: enabled,
      value: curDate?.toLocal(),
      onTap: (BuildContext context) async {
        return _pickDateTime(context, initialDate: curDate ?? DateTime.now())
            .then(
          (pickedDateTime) => pickedDateTime != null
              ? updateDateTime(ref, pickedDateTime)
              : null,
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate.toLocal()),
      );
      FocusManager.instance.primaryFocus?.unfocus();

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
    return date == null ? label(context) : dayFormat.format(date);
  }

  String? _validator(DateTime? date) {
    return null;

    // return date == null ? 'Due date is required' : null;
  }
}
