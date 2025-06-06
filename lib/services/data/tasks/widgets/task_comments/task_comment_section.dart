import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_comment_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/task_comments_repository.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comment_model.dart';

class TaskCommentSection extends HookConsumerWidget {
  const TaskCommentSection(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTextField = useState(false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.comments,
                  style: Theme.of(context).textTheme.titleMedium),
              if (!showTextField.value)
                IconButton(
                  onPressed: () => showTextField.value = true,
                  tooltip: AppLocalizations.of(context)!.addComment,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          StreamBuilder(
            stream: ref.watch(taskCommentsRepositoryProvider).watchTaskComments(
                  taskId: taskId,
                ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final comments = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    TaskCommentCard(comments[index]),
              );
            },
          ),
          if (showTextField.value)
            _TaskCommentField(
              taskId: taskId,
              afterSubmit: () {
                showTextField.value = false;
              },
            ),
        ],
      ),
    );
  }
}

class _TaskCommentField extends BaseTaskCommentField {
  _TaskCommentField({
    required this.taskId,
    required this.afterSubmit,
  }) : super(
          enabled: true,
          addComment: (ref, text) async {
            final curAuthUser = ref.read(curUserProvider).value;

            if (curAuthUser == null) {
              throw UnauthorizedException();
            }

            final comment = TaskCommentModel(
              parentTaskId: taskId,
              content: text,
              authorUserId: curAuthUser.id,
            );
            ref.read(taskCommentsRepositoryProvider).upsertItem(comment);

            afterSubmit();
          },
        );

  final String taskId;

  /// Callback to be called after the comment is sent
  /// 
  /// Currently used to hide the comment field after the comment is sent
  final VoidCallback afterSubmit;
}
