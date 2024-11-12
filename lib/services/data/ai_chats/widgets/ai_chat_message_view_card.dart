import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/common/utils/string_extension.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_action_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_info_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_request_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/requests/ai_ui_action_request_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_type.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';

class AiChatMessageViewCard extends HookWidget {
  final AiChatMessageModel message;

  const AiChatMessageViewCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDebugMode = useState(false);
    final displayType = message.type;
    final theme = Theme.of(context);

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
                        value: displayType.toString(),
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
                    AiChatMessageType.user => Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(message.content),
                        ),
                      ),
                    AiChatMessageType.ai =>
                      _buildAiMessageWidget(message.content),
                    // AiChatMessageDisplayType.aiWithToolCall =>
                    //   _buildAiMessageWidget(message.content),
                    // AiChatMessageDisplayType.toolAiRequest =>
                    //   _buildAiRequestWidget(message.getAiRequest()!, context),
                    // AiChatMessageDisplayType.toolAiResult =>
                    //   _buildAiRequestResultWidget(message.getAiResult()!),
                    AiChatMessageType.tool => Text(message.content),
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
            key: 'Action Type',
            value: request.actionRequestType.value,
            context: context,
          ),
        ] else if (request is AiInfoRequestModel) ...[
          _buildKeyValueText(
            key: 'Info Type',
            value: request.infoRequestType.value,
            context: context,
          ),
          _buildKeyValueText(
            key: 'Show Only',
            value: request.showOnly.toString(),
            context: context,
          )
        ] else if (request is AiUiActionRequestModel)
          _buildKeyValueText(
            key: 'UI Action Type',
            value: request.uiActionType.value,
            context: context,
          ),

        // Display arguments if present
        // if (request.args != null && request.args!.isNotEmpty)
        //   ...request.args!.entries.map((entry) => _buildKeyValueText(
        //         key: entry.key,
        //         value: jsonEncode(entry.value),
        //         context: context,
        //       ))
        // else
        //   const Text('No arguments provided'),
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

  // Widget _buildAiRequestResultWidget(AiRequestResultModel result) {
  //   Widget icon = const Icon(Icons.info,
  //       size: 24.0); // Small icon to indicate result type
  //   return Column(
  //     children: [
  //       icon,
  //       const SizedBox(width: 6.0), // Space between icon and result widget
  //       switch (result.resultType) {
  //         AiRequestResultType.shiftAssignments => ShiftAssignmentsResultWidget(
  //             result: result as ShiftAssignmentsResultModel),
  //         AiRequestResultType.shiftLogs =>
  //           ShiftLogsResultWidget(result: result as ShiftLogsResultModel),
  //         AiRequestResultType.shiftClockInOut => ShiftClockInOutResultWidget(
  //             result: result as ShiftClockInOutResultModel),
  //         AiRequestResultType.error => Text(result.resultForAi),
  //       },
  //     ],
  //   );
  // }
}
