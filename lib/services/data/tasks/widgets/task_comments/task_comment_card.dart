import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskCommentCard extends ConsumerWidget {
  const TaskCommentCard(this.comment, {super.key});
  final TaskCommentModel comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorFuture =
        ref.watch(usersRepositoryProvider).getById(comment.authorUserId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel?>(
              future: authorFuture,
              builder: (context, snapshot) {
                final author = snapshot.data;
                if (author == null) return const CircularProgressIndicator();

                return Row(
                  children: [
                    UserAvatar(author, radius: 12),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        author.firstName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat.MMMMd(AppLocalizations.of(context)!.localeName)
                          .add_jm()
                          .format(comment.updatedAt?.toLocal() ??
                              comment.createdAt!.toLocal()),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(comment.content ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
