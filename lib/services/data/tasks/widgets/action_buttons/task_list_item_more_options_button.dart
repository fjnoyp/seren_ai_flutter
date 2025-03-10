import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/action_buttons/delete_task_button.dart';

class TaskListItemMoreOptionsButton extends StatelessWidget {
  const TaskListItemMoreOptionsButton({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final controller = MenuController();
    return MenuAnchor(
      controller: controller,
      crossAxisUnconstrained: false,
      builder: (context, controller, child) => IconButton(
        icon: const Icon(Icons.more_vert, size: 18),
        onPressed: controller.isOpen ? controller.close : controller.open,
      ),
      menuChildren: [
        DeleteTaskButton(
          taskId,
          showLabelText: true,
          onDelete: controller.close,
        ),
      ],
    );
  }
}
