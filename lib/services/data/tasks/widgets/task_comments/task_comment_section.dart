import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_comment_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_comments/joined_task_comments_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/ui_state/cur_task_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/task_comments/task_comment_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskCommentSection extends ConsumerStatefulWidget {
  const TaskCommentSection(this.taskId, {super.key});

  final String taskId;

  @override
  ConsumerState<TaskCommentSection> createState() => _TaskCommentSectionState();
}

class _TaskCommentSectionState extends ConsumerState<TaskCommentSection> {
  bool showTextField = false;

  @override
  Widget build(BuildContext context) {
    final joinedComments =
        ref.watch(joinedTaskCommentsListenerFamProvider(widget.taskId));
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.comments, 
                   style: theme.textTheme.titleMedium),
              if (!showTextField)
                IconButton(
                  onPressed: () => setState(() => showTextField = true),
                  tooltip: AppLocalizations.of(context)!.addComment,
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
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                TaskCommentCard(joinedComments![index]),
          ),
          if (showTextField)
            _TaskCommentField(
              onSubmit: () => setState(() {
                showTextField = false;
              }),
            ),
        ],
      ),
    );
  }
}

class _TaskCommentField extends BaseTaskCommentField {
  _TaskCommentField({required this.onSubmit})
      : super(
          enabled: true,
          commentProvider: curTaskProvider.select((state) => ''),
          addComment: (ref, text) {
            ref.read(curTaskProvider.notifier).addComment(text);
            onSubmit();
          },
        );

  final VoidCallback onSubmit;
}
