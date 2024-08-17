import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_orchestrator_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_form/color_animation.dart';

class AnimatedModalSelectionField<T> extends HookConsumerWidget {
  const AnimatedModalSelectionField({
    super.key,
    required this.labelWidget,
    required this.validator,
    required this.valueToString,
    required this.enabled,
    required this.value,
    required this.options,
    required this.onValueChanged,
  });

  final Widget labelWidget;
  final String? Function(T?) validator;
  final String Function(T?) valueToString;
  final bool enabled;
  final T? value;
  final List<T> options;
  final void Function(WidgetRef, T?) onValueChanged;

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
            onValueChanged3: onValueChanged,
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
    required super.onValueChanged3,
    //required super.onValueChanged,
    required super.labelWidget,
    required List<T> options,
    required super.valueToString,
    //super.onSaved,
    super.validator,
    super.enabled,
    //super.onValueChanged2,
    super.defaultColor,
  }) : super(
          showSelectionModal: (BuildContext context,
              void Function(WidgetRef, T)? onValueChanged3) async {
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
                          //ref.read(curTaskProvider.notifier).updateParentProject(ProjectModel(name: 'test', description: 'test', parentOrgId: 'test', parentTeamId: 'test'));

                          onValueChanged3?.call(ref, option);
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
    required super.onValueChanged3,
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
          onValueChanged3: onValueChanged3,
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
  final Future<void> Function(BuildContext, void Function(WidgetRef, T)?)
      showSelectionModal;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final T? value;
  final void Function(WidgetRef, T)? onValueChanged3;

  final Color? defaultColor;

  const SelectionField({
    Key? key,
    required this.labelWidget,
    required this.valueToString,
    required this.showSelectionModal,
    required this.value,
    required this.onValueChanged3,
    // This is unused - must implement validator ui manually
    this.validator,
    this.enabled = true,
    this.defaultColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {



    
    final Color baseColor = defaultColor ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        Colors.black;

    final Color curColor = enabled ? baseColor : Color.lerp(baseColor, Colors.grey[600], 0.5)!;
    //final Color curColor = baseColor;
    

  

    return  Row(
            children: [
              // Label Widget

              /*
        ColorFiltered(
          colorFilter: ColorFilter.mode(curColor, BlendMode.srcIn),
          child: labelWidget,
        ),
        */

              
              //DefaultTextStyle(
//                style: TextStyle(color: curColor),
                //child: labelWidget,
              //),
              labelWidget,
              const SizedBox(width: 8),
              Expanded(
                // Button to show selection UI
                child: TextButton(
                  onPressed: enabled
                      ? () async {
                          // Using ShowBottomSheet or ShowDatePicker invalidates the ref context after the modal closes
                          // Only fix has been to use consumer directly in the modal builder when the tap occurs
                          await showSelectionModal(context, onValueChanged3);
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
                        color: curColor),
                        //backgroundColor: enabled ? null : Colors.grey[200],
                        //),
                  ),
                ),
              ),
            ],
          );
  }
}
