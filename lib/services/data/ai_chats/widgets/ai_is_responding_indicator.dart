import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AiIsRespondingIndicator extends StatelessWidget {
  const AiIsRespondingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: SizedBox(
            width: 24.0, // Adjust width as needed
            height: 24.0, // Adjust height as needed
            child: SvgPicture.asset('assets/images/AI button.svg'),
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24, top: 24, right: 24),
            child: JumpingDotsIndicator(),
          ),
        ),
      ],
    );
  }
}


class JumpingDotsIndicator extends HookWidget {
  const JumpingDotsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Durations.extralong4,
    );

    final animations = useMemoized(
      () => List.generate(
        3,
        (index) => TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0, end: -6),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -6, end: 0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              index * 0.2, // Start at 0.0, 0.2, 0.4
              index * 0.2 + 0.5, // End at 0.6, 0.8, 1.0
              curve: Curves.linear,
            ),
          ),
        ),
      ),
      [controller],
    );

    useEffect(() {
      controller.repeat();
      return controller.dispose;
    }, [controller]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: animations[index],
              builder: (context, child) => Transform.translate(
                offset: Offset(0, animations[index].value),
                child: child,
              ),
              child: Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
