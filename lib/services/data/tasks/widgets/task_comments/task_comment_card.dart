import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_comments_model.dart';

class TaskCommentCard extends StatelessWidget {
  const TaskCommentCard(
    this.comment, {
    super.key,
  });

  final JoinedTaskCommentsModel comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  radius: 12.0,
                  // TODO: replace with authorPhotoUrl Image (.network?)
                  child: Text(comment.authorUser!.email[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    // TODO: replace with authorName
                    comment.authorUser!.email,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('MMMM, d   hh:mm a').format(
                      comment.comment.updatedAt?.toLocal() ??
                          comment.comment.createdAt!.toLocal()),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(comment.comment.content ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
