import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_comments/joined_task_comments_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_card.dart';

class TaskCommentSection extends ConsumerWidget {
  const TaskCommentSection(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedComments = ref.watch(joinedTaskCommentsListenerFamProvider(taskId));
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(children: [
        Row(
          children: [
            Text('Comments', style: theme.textTheme.titleMedium),
            // TODO: implement onPressed
            IconButton(
              onPressed: () {},
              tooltip: 'Add Comment',
              icon: Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: joinedComments?.length ?? 0,
          itemBuilder: (context, index) => TaskCommentCard(joinedComments![index]),
        ),
      ]),
    );
  }
}
