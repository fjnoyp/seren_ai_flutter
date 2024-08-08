import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';

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

class SelectionField<T> extends ConsumerWidget {
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

    final Color baseColor = defaultColor ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final Color curColor = enabled ? baseColor : Color.lerp(baseColor, Colors.grey[600], 0.5)!;

    return Row(
      children: [
        // Label Widget
        ColorFiltered(
          colorFilter: ColorFilter.mode(curColor, BlendMode.srcIn),
          child: labelWidget,
        ),
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
                    color: curColor
                    //backgroundColor: enabled ? null : Colors.grey[200],
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
