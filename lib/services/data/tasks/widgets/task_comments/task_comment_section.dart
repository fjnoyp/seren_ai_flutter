import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/base_task_comment_field.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_service_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/cur_task_state_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/joined_task_comments_provider.dart';
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
          AsyncValueHandlerWidget(
            value: ref.watch(joinedTaskCommentsProvider),
            data: (joinedComments) => ListView.builder(
              shrinkWrap: true,
              itemCount: joinedComments?.length ?? 0,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  TaskCommentCard(joinedComments![index]),
            ),
            error: (e, st) => throw Exception(e),
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
          commentProvider: curTaskStateProvider.select((state) => ''),
          addComment: (ref, text) {
            ref.read(curTaskServiceProvider).addComment(text);
            onSubmit();
          },
        );

  final VoidCallback onSubmit;
}
