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
  });

  final bool isEditable;
  final ProviderListenable<String> nameProvider;
  final Function(WidgetRef, String) updateName;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curName = ref.watch(nameProvider);
    final nameController = useTextEditingController(text: curName);
    final focusNode = useFocusNode();

    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      triggerValue: curName,
    );

    // HACK to get textController to sync with curTaskProvider
    // The onSubmitted event is never called
    // And updating state onChanged will reset the TextField

    // TODO: p2 - should remove hack and find better solution
    // Current approach will NOT work with keyboards and button is pressed, as submit event is never triggered

    /*
    focusNode.addListener(() {
      if (!focusNode.hasFocus && nameController.text != curTaskName) {
        ref.read(curTaskProvider.notifier).updateTaskName(nameController.text);
        FocusScope.of(context).unfocus(); // Hide the keyboard
      }
    });
    */

    // Add focus listener using useEffect to properly handle tap outside for web
    useEffect(() {
      void onFocusChange() {
        if (!focusNode.hasFocus && nameController.text != curName) {
          updateName(ref, nameController.text);
          FocusScope.of(context).unfocus();
        }
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, [focusNode]);

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        nameController.text = curName;
        return TextField(
          minLines: 1,
          maxLines: null,
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
            filled: false,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
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
