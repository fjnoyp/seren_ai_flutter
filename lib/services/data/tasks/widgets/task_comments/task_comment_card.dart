import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';
import 'package:seren_ai_flutter/services/data/users/models/user_model.dart';
import 'package:seren_ai_flutter/services/data/users/repositories/users_repository.dart';

class TaskCommentCard extends HookConsumerWidget {
  const TaskCommentCard(this.comment, {super.key});
  final TaskCommentModel comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorFuture =
        ref.watch(usersRepositoryProvider).getById(comment.authorUserId);

    // Add color animation for new comments when AI is responding
    final colorAnimation = useAiActionColorAnimation(
      context,
      ref,
      triggerValue: comment.id,
    );

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
                              comment.createdAt?.toLocal() ??
                              DateTime.now().toLocal()),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: colorAnimation.colorTween,
                builder: (context, child) {
                  return Text(
                    comment.content ?? '',
                    style: TextStyle(
                      color: colorAnimation.colorTween.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
