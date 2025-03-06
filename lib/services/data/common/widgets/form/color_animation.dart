import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_responding_provider.dart';

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

ColorAnimation useAiActionColorAnimation(BuildContext context, WidgetRef ref,
    {Duration duration = const Duration(seconds: 3),
    required dynamic triggerValue}) {
  final colorAnimation = useColorAnimation(
    duration: duration,
    begin: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
    end: Colors.red,
  );

  useEffect(() {
    // Capture the value once when the effect runs
    final shouldAnimate = ref.read(isAiRespondingProvider);

    // Only start animation if it should animate
    if (shouldAnimate) {
      colorAnimation.controller
          .forward()
          .then((_) => colorAnimation.controller.reverse());
    }
    return null;
  }, [triggerValue]);

  return ColorAnimation(colorAnimation.colorTween, colorAnimation.controller);
}
