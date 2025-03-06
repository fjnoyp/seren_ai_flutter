import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';

class BaseNameField extends HookConsumerWidget {
  const BaseNameField({
    super.key,
    required this.isEditable,
    required this.nameProvider,
    required this.updateName,
    this.textStyle,
    this.focusNode,
  });

  final bool isEditable;
  final ProviderListenable<String> nameProvider;
  final Function(WidgetRef, String) updateName;
  final TextStyle? textStyle;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curName = ref.watch(nameProvider);
    final nameController = useTextEditingController(text: curName);
    final focusNode = this.focusNode ?? useFocusNode();

    // Track if we've already got the name to ensure we only set the selection once
    final isFirstCurNameLoad = useRef(true);

    // Wrap the selection logic in useEffect to ensure it only runs when dependencies change
    useEffect(() {
      // Only set selection when it has (auto)focus and we have a non-empty name for the first time
      if (focusNode.hasFocus &&
          curName.isNotEmpty &&
          isFirstCurNameLoad.value) {
        // Add a microtask to ensure the controller is ready before setting selection
        Future.microtask(() {
          if (nameController.text.isNotEmpty) {
            nameController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: nameController.text.length,
            );
            isFirstCurNameLoad.value = false;
          }
        });
      }
      return null;
    }, [curName]);

    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      triggerValue: curName,
    );

    useEffect(() {
      nameController.text = curName;
      return null;
    }, [curName]);

    // Update the task name only when editing is complete or when tapping outside
    void updateTaskName() {
      if (nameController.text != curName) {
        updateName(ref, nameController.text);
      }
      FocusScope.of(context).unfocus(); // Hide the keyboard
    }

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        // nameController.text = curName;
        return TextField(
          minLines: 1,
          maxLines: null,
          focusNode: focusNode,
          controller: nameController,
          enabled: isEditable,
          textInputAction: TextInputAction.done,
          onEditingComplete: updateTaskName, // Update on editing complete
          onTapOutside: (_) {
            updateTaskName(); // Update on tap outside
          },
          decoration: InputDecoration(
            hintText: 'Enter name',
            errorText: curName.isEmpty ? 'Name is required' : null,
            // if we set filled to false, hover color will not work
            fillColor: Colors.transparent,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            hoverColor: Theme.of(context).colorScheme.primary.withAlpha(25),
          ),
          style: (textStyle ?? Theme.of(context).textTheme.headlineMedium)
              ?.copyWith(
            color: colorAnimation.colorTween.value,
          ),
        );
      },
    );
  }
}
