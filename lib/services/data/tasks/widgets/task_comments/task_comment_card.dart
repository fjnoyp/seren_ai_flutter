import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_comments_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class TaskCommentCard extends StatelessWidget {
  const TaskCommentCard(
    this.comment, {
    super.key,
  });

  final JoinedTaskCommentsModel comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(comment.authorUser!, radius: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comment.authorUser!.firstName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat.MMMMd(AppLocalizations.of(context)!.localeName)
                      .add_jm()
                      .format(comment.comment.updatedAt?.toLocal() ??
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
