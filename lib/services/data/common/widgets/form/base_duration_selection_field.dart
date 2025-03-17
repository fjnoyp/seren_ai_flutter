import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/selection_field.dart';

class BaseDurationSelectionField extends ConsumerWidget {
  final bool enabled;
  final ProviderListenable<int?> durationProvider;
  final Function(WidgetRef, int?) updateDuration;

  const BaseDurationSelectionField({
    super.key,
    required this.enabled,
    required this.durationProvider,
    required this.updateDuration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curDuration = ref.watch(durationProvider);

    return AnimatedSelectionField<int>(
      labelWidget: const Icon(Icons.timer_outlined),
      validator: (_) => null,
      valueToString: (value) {
        if (value == null || value == 0) {
          return AppLocalizations.of(context)!.noEstimatedDuration;
        }

        final days = value ~/ 1440;
        final hours = (value % 1440) ~/ 60;

        return AppLocalizations.of(context)!.durationDaysAndHours(days, hours);
      },
      enabled: enabled,
      value: curDuration,
      onValueChanged: (ref, value) => updateDuration(ref, value),
      onTap: (BuildContext context) async {
        final result = await showDialog<int>(
          context: context,
          builder: (context) => _DurationPickerDialog(
            initialDuration: curDuration ?? 0,
          ),
        );

        if (result != null) {
          updateDuration(ref, result > 0 ? result : null);
        }
        return result;
      },
    );
  }
}

class _DurationPickerDialog extends HookWidget {
  final int initialDuration;

  const _DurationPickerDialog({required this.initialDuration});

  @override
  Widget build(BuildContext context) {
    // Initialize days and hours state with hooks
    final days = useState(initialDuration ~/ 1440);
    final hours = useState((initialDuration % 1440) ~/ 60);

    // Create TextEditingControllers with hooks
    final daysController =
        useTextEditingController(text: days.value.toString());
    final hoursController =
        useTextEditingController(text: hours.value.toString());

    // Update controllers when values change
    useEffect(() {
      daysController.text = days.value.toString();
      return null;
    }, [days.value]);

    useEffect(() {
      hoursController.text = hours.value.toString();
      return null;
    }, [hours.value]);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.estimatedDuration),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: days.value > 0 ? () => days.value-- : null,
                  ),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: _DurationTextField(
                      controller: daysController,
                      onChanged: (value) => days.value = value,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => days.value++,
                  ),
                  Text(' ${AppLocalizations.of(context)!.day.toLowerCase()}s'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: hours.value > 0 ? () => hours.value-- : null,
                  ),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: _DurationTextField(
                      controller: hoursController,
                      onChanged: (value) => hours.value = value,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => hours.value++,
                  ),
                  Text(' ${AppLocalizations.of(context)!.hours.toLowerCase()}'),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            // Convert days and hours back to minutes
            final totalMinutes = (days.value * 1440) + (hours.value * 60);
            Navigator.pop(context, totalMinutes);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}

class _DurationTextField extends TextField {
  _DurationTextField({
    required super.controller,
    required Function(int) onChanged,
  }) : super(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            final newValue = int.tryParse(value);
            if (newValue != null && newValue >= 0) {
              onChanged(newValue);
            }
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(),
          ),
        );
}
