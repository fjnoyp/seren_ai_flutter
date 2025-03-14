import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/ai/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_result_widgets.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/add_comment_to_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/delete_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/task_result_widgets.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AiChatMessageViewCard extends HookConsumerWidget {
  final AiChatMessageModel message;

  const AiChatMessageViewCard({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(isDebugModeSNP);
    final showRawJson = useState(false);
    final displayType = message.getDisplayType();
    final theme = Theme.of(context);

    // Exception case for empty messages
    if (message.content.isEmpty) {
      return const SizedBox.shrink();
    }

    final messageDisplay = switch (displayType) {
      AiChatMessageDisplayType.user => _UserMessageWidget(message.content),
      AiChatMessageDisplayType.ai => _AiMessageWidget(message.content),
      AiChatMessageDisplayType.aiWithToolCall =>
        _AiMessageWidget(message.getAiMessage() ?? message.content),
      AiChatMessageDisplayType.toolAiRequest => const SizedBox.shrink(),
      // _AiRequestWidget(message.getAiRequest()!),
      AiChatMessageDisplayType.toolAiResult =>
        _AiRequestResultWidget(message.getAiResult()!),
      AiChatMessageDisplayType.tool => const SizedBox.shrink(),
      // Text(message.content),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: isDebugMode
          ? Card(
              child: Column(
                children: [
                  // Debug Mode Toggle - Positioned in top right
                  if (ref.watch(isDebugModeSNP))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.only(right: 6, top: 6),
                          constraints: const BoxConstraints(),
                          iconSize: 15,
                          icon: const Icon(Icons.copy),
                          color: theme.colorScheme.primary,
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: message.content));
                          },
                        ),
                        IconButton(
                          padding: const EdgeInsets.only(right: 6, top: 6),
                          constraints: const BoxConstraints(),
                          iconSize: 15,
                          icon: Icon(
                            showRawJson.value ? Icons.list : Icons.bug_report,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () =>
                              showRawJson.value = !showRawJson.value,
                        ),
                      ],
                    ),
                  showRawJson.value
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _KeyValueText(
                                key: 'Display Type',
                                value: displayType.toHumanReadable(context),
                                context: context,
                              ),
                              _KeyValueText(
                                key: 'ID',
                                value: message.id,
                                context: context,
                              ),
                              _KeyValueText(
                                key: 'Thread ID',
                                value: message.parentChatThreadId,
                                context: context,
                              ),
                              if (message.parentLgRunId != null)
                                _KeyValueText(
                                  key: 'LG Run ID',
                                  value: message.parentLgRunId!,
                                  context: context,
                                ),
                              _KeyValueText(
                                key: 'Content',
                                value: message.content.tryFormatAsJson(),
                                context: context,
                                valueStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: messageDisplay,
                        ),
                ],
              ),
            )
          : messageDisplay,
    );
  }
}

class _KeyValueText extends StatelessWidget {
  final String value;
  final TextStyle? valueStyle;
  final BuildContext context;

  _KeyValueText({
    required String key,
    required this.value,
    this.valueStyle,
    required this.context,
  }) : super(key: Key(key));

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$key: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value, style: valueStyle),
        ],
      ),
    );
  }
}

class _UserMessageWidget extends StatelessWidget {
  final String message;

  const _UserMessageWidget(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _CollapsibleText(
                  message,
                  alignment: AlignmentDirectional.centerEnd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMessageWidget extends StatelessWidget {
  final String message;

  const _AiMessageWidget(this.message);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: SvgPicture.asset('assets/images/AI button.svg'),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _CollapsibleText(message),
            ),
          ),
        ),
      ],
    );
  }
}

// class _AiRequestWidget extends StatelessWidget {
//   final AiRequestModel request;

//   const _AiRequestWidget(this.request);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _KeyValueText(
//           key: 'Request Type',
//           value: request.requestType.value,
//           context: context,
//         ),

//         // Show subtype based on request model type
//         if (request case AiActionRequestModel actionRequest) ...[
//           _KeyValueText(
//             key: AppLocalizations.of(context)!.actionType,
//             value: actionRequest.actionRequestType.value,
//             context: context,
//           ),
//         ] else if (request case AiInfoRequestModel infoRequest) ...[
//           _KeyValueText(
//             key: AppLocalizations.of(context)!.infoType,
//             value: infoRequest.infoRequestType.value,
//             context: context,
//           ),
//           _KeyValueText(
//             key: AppLocalizations.of(context)!.showOnly,
//             value: infoRequest.showOnly.toString(),
//             context: context,
//           )
//         ] else if (request case AiUiActionRequestModel uiActionRequest) ...[
//           _KeyValueText(
//             key: AppLocalizations.of(context)!.uiActionType,
//             value: uiActionRequest.uiActionType.value,
//             context: context,
//           ),

//           // Display arguments if present
//           if (request.args != null && request.args!.isNotEmpty)
//             ...request.args!.entries.map((entry) => _KeyValueText(
//                   key: entry.key,
//                   value: jsonEncode(entry.value),
//                   context: context,
//                 ))
//           else
//             Text(AppLocalizations.of(context)!.noArgumentsProvided),
//         ],
//       ],
//     );
//   }
// }

class _AiRequestResultWidget extends StatelessWidget {
  final AiRequestResultModel result;

  const _AiRequestResultWidget(this.result);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 1, color: Theme.of(context).dividerColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: switch (result.resultType) {
          AiRequestResultType.shiftAssignments => ShiftAssignmentsResultWidget(
              result: result as ShiftAssignmentsResultModel),
          AiRequestResultType.shiftLogs =>
            ShiftLogsResultWidget(result: result as ShiftLogsResultModel),
          AiRequestResultType.shiftClockInOut => ShiftClockInOutResultWidget(
              result: result as ShiftClockInOutResultModel),
          AiRequestResultType.findTasks =>
            FindTasksResultWidget(result: result as FindTasksResultModel),
          AiRequestResultType.createTask =>
            CreateTaskResultWidget(result: result as CreateTaskResultModel),
          AiRequestResultType.error => Text(result.resultForAi),
          AiRequestResultType.updateTaskFields => UpdateTaskFieldsResultWidget(
              result: result as UpdateTaskFieldsResultModel),
          AiRequestResultType.deleteTask =>
            DeleteTaskResultWidget(result: result as DeleteTaskResultModel),
          AiRequestResultType.addCommentToTask => AddCommentToTaskResultWidget(
              result: result as AddCommentToTaskResultModel),
        },
      ),
    );
  }
}

class _CollapsibleText extends HookWidget {
  const _CollapsibleText(
    this.content, {
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String content;
  final AlignmentDirectional alignment;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    return content.length > 200 && !isExpanded.value
        ? Wrap(
            children: [
              Text('${content.substring(0, 200)}...',
                  textAlign: switch (alignment) {
                    AlignmentDirectional.topStart ||
                    AlignmentDirectional.centerStart ||
                    AlignmentDirectional.bottomStart =>
                      TextAlign.left,
                    AlignmentDirectional.topEnd ||
                    AlignmentDirectional.centerEnd ||
                    AlignmentDirectional.bottomEnd =>
                      TextAlign.right,
                    _ => TextAlign.center,
                  }),
              Align(
                alignment: alignment,
                child: TextButton(
                  child: const Text('Show more'),
                  onPressed: () => isExpanded.value = true,
                ),
              ),
            ],
          )
        : Text(content);
  }
}
