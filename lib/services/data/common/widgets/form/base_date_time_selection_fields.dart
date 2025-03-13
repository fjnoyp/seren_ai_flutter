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
          dateLabel: ((context) => AppLocalizations.of(context)!.chooseDueDate),
          timeLabel: ((context) => AppLocalizations.of(context)!.chooseDueTime),
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
          dateLabel: ((context) =>
              AppLocalizations.of(context)!.chooseStartDate),
          timeLabel: ((context) =>
              AppLocalizations.of(context)!.chooseStartTime),
        );
}

class _BaseDateTimeSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<DateTime?> dateTimeProvider;
  final Function(WidgetRef, DateTime) updateDateTime;
  final String Function(BuildContext) dateLabel;
  final String Function(BuildContext) timeLabel;

  const _BaseDateTimeSelectionField({
    super.key,
    required this.enabled,
    required this.dateTimeProvider,
    required this.updateDateTime,
    required this.dateLabel,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDateTime = ref.watch(dateTimeProvider);

    return Row(
      children: [
        Flexible(
          child: AnimatedSelectionField<DateTime>(
            labelWidget: const Icon(Icons.date_range),
            validator: _validator,
            valueToString: (date) => _valueToDate(date, context: context),
            enabled: enabled,
            value: curDateTime?.toLocal(),
            onTap: (BuildContext context) async {
              return _pickDate(context,
                      initialDate: curDateTime ?? DateTime.now())
                  .then(
                (pickedDateTime) => pickedDateTime != null
                    ? updateDateTime(
                        ref,
                        pickedDateTime.copyWith(
                            hour: curDateTime?.hour ?? 0,
                            minute: curDateTime?.minute ?? 0),
                      )
                    : null,
              );
            },
          ),
        ),
        Flexible(
          child: AnimatedSelectionField<TimeOfDay>(
            labelWidget: const Icon(Icons.access_time),
            valueToString: (time) =>
                time == null ? timeLabel(context) : time.format(context),
            enabled: enabled,
            value: _timeOfDayFromCurDateTime(curDateTime),
            onTap: (BuildContext context) async {
              return _pickTime(context,
                      initialTime: _timeOfDayFromCurDateTime(curDateTime) ??
                          const TimeOfDay(hour: 0, minute: 0))
                  .then(
                (pickedTime) => pickedTime != null
                    ? updateDateTime(
                        ref,
                        (curDateTime ?? DateTime.now()).copyWith(
                          hour: pickedTime.hour,
                          minute: pickedTime.minute,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  TimeOfDay? _timeOfDayFromCurDateTime(DateTime? curDateTime) =>
      curDateTime != null
          ? TimeOfDay.fromDateTime(curDateTime.toLocal())
          : null;

  Future<DateTime?> _pickDate(
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
    FocusManager.instance.primaryFocus?.unfocus();

    return pickedDate?.toLocal();
  }

  Future<TimeOfDay?> _pickTime(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    FocusManager.instance.primaryFocus?.unfocus();

    return pickedTime;
  }

  String _valueToDate(DateTime? date, {required BuildContext context}) {
    final dayFormat = DateFormat.yMd(AppLocalizations.of(context)!.localeName);
    return date == null ? dateLabel(context) : dayFormat.format(date);
  }

  String? _validator(DateTime? date) {
    return null;

    // return date == null ? 'Due date is required' : null;
  }
}
