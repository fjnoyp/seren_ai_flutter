import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_result_widgets.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/update_task_fields_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/task_result_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiChatMessageViewCard extends HookWidget {
  final AiChatMessageModel message;  

  const AiChatMessageViewCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDebugMode = useState(false);
    final displayType = message.getDisplayType();
    final theme = Theme.of(context);

    // Exception case for empty messages
    if (message.content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content starts with some top padding to avoid overlap with debug button
                const SizedBox(height: 8),
                if (isDebugMode.value)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKeyValueText(
                        key: 'Display Type',
                        value: displayType.toHumanReadable(context),
                        context: context,
                      ),
                      _buildKeyValueText(
                        key: 'ID',
                        value: message.id,
                        context: context,
                      ),
                      _buildKeyValueText(
                        key: 'Thread ID',
                        value: message.parentChatThreadId,
                        context: context,
                      ),
                      if (message.parentLgRunId != null)
                        _buildKeyValueText(
                          key: 'LG Run ID',
                          value: message.parentLgRunId!,
                          context: context,
                        ),
                      _buildKeyValueText(
                        key: 'Content',
                        value: message.content.tryFormatAsJson(),
                        context: context,
                        valueStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                      ),
                    ],
                  ),

                if (!isDebugMode.value)
                  switch (displayType) {
                    AiChatMessageDisplayType.user => Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(message.content),
                        ),
                      ),
                    AiChatMessageDisplayType.ai =>
                      _buildAiMessageWidget(message.content),
                    AiChatMessageDisplayType.aiWithToolCall =>
                      _buildAiMessageWidget(
                          message.getAiMessage() ?? message.content),
                    AiChatMessageDisplayType.toolAiRequest =>
                      _buildAiRequestWidget(message.getAiRequest()!, context),
                    AiChatMessageDisplayType.toolAiResult =>
                      _buildAiRequestResultWidget(
                          message.getAiResult()!, context),
                    AiChatMessageDisplayType.tool => Text(message.content),
                  },
              ],
            ),
          ),

          // Debug Mode Toggle - Positioned in top right
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 15,
              icon: Icon(
                isDebugMode.value ? Icons.list : Icons.bug_report,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => isDebugMode.value = !isDebugMode.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessageWidget(String message) {
    return Column(
      children: [
        SizedBox(
          width: 24.0, // Adjust width as needed
          height: 24.0, // Adjust height as needed
          child: SvgPicture.asset('assets/images/AI button.svg'),
        ),
        const SizedBox(height: 8.0), // Space between icon and text
        Text(message),
      ],
    );
  }

  Widget _buildAiRequestWidget(AiRequestModel request, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKeyValueText(
          key: 'Request Type',
          value: request.requestType.value,
          context: context,
        ),

        // Show subtype based on request model type
        if (request is AiActionRequestModel) ...[
          _buildKeyValueText(
            key: AppLocalizations.of(context)!.actionType,
            value: request.actionRequestType.value,
            context: context,
          ),
        ] else if (request is AiInfoRequestModel) ...[
          _buildKeyValueText(
            key: AppLocalizations.of(context)!.infoType,
            value: request.infoRequestType.value,
            context: context,
          ),
          _buildKeyValueText(
            key: AppLocalizations.of(context)!.showOnly,
            value: request.showOnly.toString(),
            context: context,
          )
        ] else if (request is AiUiActionRequestModel)
          _buildKeyValueText(
            key: AppLocalizations.of(context)!.uiActionType,
            value: request.uiActionType.value,
            context: context,
          ),

        // Display arguments if present
        if (request.args != null && request.args!.isNotEmpty)
          ...request.args!.entries.map((entry) => _buildKeyValueText(
                key: entry.key,
                value: jsonEncode(entry.value),
                context: context,
              ))
        else
          Text(AppLocalizations.of(context)!.noArgumentsProvided),
      ],
    );
  }

  Widget _buildKeyValueText({
    required String key,
    required String value,
    TextStyle? valueStyle,
    required BuildContext context,
  }) {
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

  Widget _buildAiRequestResultWidget(
      AiRequestResultModel result, BuildContext context) {
    Widget icon = const Icon(Icons.info,
        size: 24.0); // Small icon to indicate result type
    return Column(
      children: [
        icon,
        const SizedBox(width: 6.0), // Space between icon and result widget
        switch (result.resultType) {
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
          AiRequestResultType.updateTaskFields =>
            UpdateTaskFieldsResultWidget(result: result as UpdateTaskFieldsResultModel),
        },
      ],
    );
  }
}
