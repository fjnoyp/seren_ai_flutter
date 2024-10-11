import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';

class BaseTaskCommentField extends HookConsumerWidget {
  const BaseTaskCommentField({
    super.key,
    required this.enabled,
    required this.commentProvider,
    required this.addComment,
  });

  final bool enabled;
  final ProviderListenable<String> commentProvider;
  final Function(WidgetRef, String) addComment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curComment = ref.watch(commentProvider);
    final commentController = useTextEditingController(text: curComment);
    final focusNode = useFocusNode();

    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      duration: const Duration(seconds: 1),
      triggerValue: curComment,
    );

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        return TextField(
          focusNode: focusNode,
          controller: commentController,
          enabled: enabled,
          textInputAction: TextInputAction.send,
          maxLines: null,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              addComment(ref, value);
            }
            FocusScope.of(context).unfocus(); // Hide the keyboard
          },
          decoration: const InputDecoration(hintText: 'Enter comment'),
          style: TextStyle(color: colorAnimation.colorTween.value),
        );
      },
    );
  }
}
