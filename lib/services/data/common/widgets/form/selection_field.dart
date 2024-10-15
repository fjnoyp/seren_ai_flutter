import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';

class AnimatedModalSelectionField<T> extends HookConsumerWidget {
  const AnimatedModalSelectionField({
    super.key,
    required this.labelWidget,
    required this.validator,
    required this.valueToString,
    required this.enabled,
    required this.value,
    required this.options,
    this.onValueChanged,
  });

  final Widget labelWidget;
  final String? Function(T?) validator;
  final String Function(T?) valueToString;
  final bool enabled;
  final T? value;
  final List<T> options;
  final void Function(WidgetRef, T?)? onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      duration: Duration(seconds: 1),
      triggerValue: value,
    );

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        return DefaultTextStyle(
          style: TextStyle(color: colorAnimation.colorTween.value),
          child: IconTheme(
            data: IconThemeData(color: colorAnimation.colorTween.value),
            child: ModalSelectionField<T>(
              labelWidget: labelWidget,
              validator: validator,
              valueToString: valueToString,
              enabled: enabled,
              value: value,
              options: options,
              onValueChanged: onValueChanged,
              defaultColor: colorAnimation.colorTween.value,
            ),
          ),
        );
      },
    );
  }
}

class ModalSelectionField<T> extends SelectionField<T> {
  ModalSelectionField({
    super.key,
    required super.value,
    super.onValueChanged,
    required super.labelWidget,
    required List<T> options,
    required super.valueToString,
    super.validator,
    super.enabled,
    super.defaultColor,
  }) : super(
          showSelectionModal: (BuildContext context) async {
            return showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final T option = options[index];
                      return ListTile(
                        title: Text(valueToString(option)),
                        onTap: () {
                          onValueChanged?.call(ref, option);
                          Navigator.pop(context, option);
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        );
}

class AnimatedSelectionField<T> extends SelectionField<T> {
  AnimatedSelectionField({
    super.key,
    required super.value,
    super.onValueChanged,
    required super.labelWidget,
    required super.valueToString,
    required super.showSelectionModal,
    super.validator,
    super.enabled,
    super.defaultColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      duration: Duration(seconds: 1),
      triggerValue: value,
    );

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        return DefaultTextStyle(
          style: TextStyle(color: colorAnimation.colorTween.value),
          child: IconTheme(
            data: IconThemeData(color: colorAnimation.colorTween.value),
            child: SelectionField<T>(
              key: key,
              value: value,
              onValueChanged: onValueChanged,
              labelWidget: labelWidget,
              valueToString: valueToString,
              showSelectionModal: showSelectionModal,
              validator: validator,
              enabled: enabled,
              defaultColor: colorAnimation.colorTween.value,
            ),
          ),
        );
      },
    );
  }
}

class SelectionField<T> extends HookConsumerWidget {
  final Widget labelWidget;
  final String Function(T?) valueToString;
  final Future<T?> Function(BuildContext) showSelectionModal;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final T? value;
  final void Function(WidgetRef, T)? onValueChanged;

  final Color? defaultColor;

  const SelectionField({
    super.key,
    required this.labelWidget,
    required this.valueToString,
    required this.showSelectionModal,
    required this.value,
    this.onValueChanged,
    this.validator,
    this.enabled = true,
    this.defaultColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color baseColor = defaultColor ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        Colors.black;

    final Color curColor =
        enabled ? baseColor : Color.lerp(baseColor, Colors.grey[600], 0.5)!;
    return FormField<T>(
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: field.hasError
                  ? const EdgeInsets.symmetric(horizontal: 8.0)
                  : const EdgeInsets.all(0),
              decoration: field.hasError
                  ? BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.error),
                      borderRadius: BorderRadius.circular(4.0),
                    )
                  : const BoxDecoration(),
              child: Row(
                children: [
                  labelWidget,
                  const SizedBox(width: 8),
                  Expanded(
                    child:
                        // Button to show selection UI
                        TextButton(
                      onPressed: enabled
                          ? () async {
                              // Using ShowBottomSheet or ShowDatePicker invalidates the ref context after the modal closes
                              // Only fix has been to use consumer directly in the modal builder when the tap occurs
                              await showSelectionModal(context).then((value) {
                                field.didChange(value);
                                field.validate();
                              });
                            }
                          : null,
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 10),
                      ),
                      // Current Value Display
                      child: Text(
                        valueToString(value),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: field.hasError
                                ? Theme.of(context).colorScheme.error
                                : curColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 10.0),
                child: Text(
                  field.errorText ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
