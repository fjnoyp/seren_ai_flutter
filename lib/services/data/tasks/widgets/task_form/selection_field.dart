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
    
  }) : super(
          showSelectionUI: (BuildContext context, void Function(WidgetRef, T)? onValueChanged3) async {
            return showModalBottomSheet(
              context: context,
              builder: (BuildContext context) => Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {   
                    return  ListView.builder(
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
  final Future<void> Function(BuildContext, void Function(WidgetRef, T)?) showSelectionUI;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final T? value;
  final void Function(WidgetRef, T)? onValueChanged3;

  const SelectionField({
    Key? key,
    
    required this.labelWidget,
    required this.valueToString,
    required this.showSelectionUI,
    required this.value,
    required this.onValueChanged3,
    // This is unused - must implement validator ui manually 
    this.validator,
    this.enabled = true,
    
    
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Label Widget
        labelWidget,
        const SizedBox(width: 8),
        Expanded(
          // Button to show selection UI
          child: TextButton(
            onPressed: enabled
                ? () async {
                    // Using ShowBottomSheet or ShowDatePicker invalidates the ref context after the modal closes 
                    // Only fix has been to use consumer directly in the modal builder when the tap occurs 
                    await showSelectionUI(context, onValueChanged3);
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
                    color: enabled ? null : Colors.grey[600],
                    backgroundColor: enabled ? null : Colors.grey[200],
                  ),
            ),
          ),
        ),
      ],
    );
  }
}