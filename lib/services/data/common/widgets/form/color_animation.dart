import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';

class ColorAnimation {
  final Animation<Color?> colorTween;
  final AnimationController controller;

  ColorAnimation(this.colorTween, this.controller);
}

ColorAnimation useColorAnimation({
  required Duration duration,
  required Color begin,
  required Color end,
}) {
  final animationController = useAnimationController(duration: duration);
  final animation = CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOutCubic,
  );
  final colorTween = ColorTween(begin: begin, end: end).animate(animation);

  return ColorAnimation(colorTween, animationController);
}


ColorAnimation useAiActionColorAnimation(BuildContext context, WidgetRef ref, {required Duration duration, required dynamic triggerValue}) {
  final colorAnimation = useColorAnimation(
    duration: duration,
    begin: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
    end: Colors.red,
  );

  useEffect(() {
    final isAiEditing = ref.read(isAiEditingProvider);

    if (!isAiEditing) return;

    colorAnimation.controller
        .forward()
        .then((_) => colorAnimation.controller.reverse());
    return null;
  }, [triggerValue]);

  return ColorAnimation(colorAnimation.colorTween, colorAnimation.controller);
}
