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
  });

  final bool isEditable;
  final ProviderListenable<String> nameProvider;
  final Function(WidgetRef, String) updateName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curName = ref.watch(nameProvider);
    final nameController = useTextEditingController(text: curName);
    final focusNode = useFocusNode();

    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      duration: const Duration(seconds: 1),
      triggerValue: curName,
    );

    // HACK to get textController to sync with curTaskProvider
    // The onSubmitted event is never called
    // And updating state onChanged will reset the TextField

    // TODO: p2 - should remove hack and find better solution
    // We can externalize the textcontroller to a provider and use it to update the state
    // (See lib/services/ai_interaction/widgets/ai_chat_text_field.dart)

    // Current approach will NOT work with keyboards and button is pressed, as submit event is never triggered

    /*
    focusNode.addListener(() {
      if (!focusNode.hasFocus && nameController.text != curTaskName) {
        ref.read(curTaskProvider.notifier).updateTaskName(nameController.text);
        FocusScope.of(context).unfocus(); // Hide the keyboard
      }
    });
    */

    return isEditable
        ? AnimatedBuilder(
            animation: colorAnimation.colorTween,
            builder: (context, child) {
              nameController.text = curName;
              return TextField(
                focusNode: focusNode,
                controller: nameController,
                enabled: isEditable,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  updateName(ref, nameController.text);
                  FocusScope.of(context).unfocus(); // Hide the keyboard
                },
                onTapOutside: (event) {
                  updateName(ref, nameController.text);
                  FocusScope.of(context).unfocus(); // Hide the keyboard
                },
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  errorText: curName.isEmpty ? 'Name is required' : null,
                ),
                style: TextStyle(color: colorAnimation.colorTween.value),
              );
            },
          )
        : Text(curName, style: Theme.of(context).textTheme.headlineMedium);
  }
}
