import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_orchestrator_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/cur_task_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TaskNameField extends HookConsumerWidget {
  const TaskNameField({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curTaskName =
        ref.watch(curTaskProvider.select((state) => state.task.name));
    final nameController = useTextEditingController(text: curTaskName);
    final focusNode = useFocusNode();

    print('TaskNameField build');
    print('    curTaskName: $curTaskName');

    /*
  final animationController =
        useAnimationController(duration: Duration(seconds: 1));
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutCubic,
    );
    final colorTween =
        ColorTween(begin: Colors.black, end: Colors.yellow).animate(animation);
        */

    final colorAnimation = useColorAnimation(
      duration: Duration(seconds: 1),
      begin: Colors.black,
      end: Colors.yellow,
    );

    // Must manually update the controller's text when the task name changes
    useEffect(() {
      final isAiEditing = ref.read(isAiEditingProvider);

      if (!isAiEditing) return;
      nameController.text = curTaskName;

      // Trigger the animation
      colorAnimation.controller
          .forward()
          .then((_) => colorAnimation.controller.reverse());
      return null;
    }, [curTaskName]);

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

    return AnimatedBuilder(
      animation: colorAnimation.colorTween,
      builder: (context, child) {
        return TextField(
          focusNode: focusNode,
          controller: nameController,
          enabled: enabled,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            ref.read(curTaskProvider.notifier).updateTaskName(value);
            FocusScope.of(context).unfocus(); // Hide the keyboard
          },
          onEditingComplete: () {
            ref
                .read(curTaskProvider.notifier)
                .updateTaskName(nameController.text);
            FocusScope.of(context).unfocus(); // Hide the keyboard
          },
          decoration: InputDecoration(
            hintText: 'Enter task name',
            errorText: curTaskName.isEmpty ? 'Task name is required' : null,
          ),
          style: TextStyle(color: colorAnimation.colorTween.value),
        );
      },
    );
  }
}

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
