import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/widgets/ai_chat_message_view_card.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_result_widgets.dart';

/// Displays the last messages from the ai
/// Including ai request + ai results
class AiResultsWidget extends HookConsumerWidget {
  const AiResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastAiResults = ref.watch(lastAiMessageListenerProvider);
    //final lastAiResults = aiRequestResults;
    final isVisible = useState(lastAiResults.isNotEmpty);

    useEffect(() {
      if (lastAiResults.isEmpty) {
        isVisible.value = false;
      } else {
        isVisible.value = true;
      }
      return null;
    }, [lastAiResults]);

    return Visibility(
      visible: isVisible.value,
      child: Container(
        //color: Theme.of(context).colorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final aiChatMessage in lastAiResults.reversed)
                        if (aiChatMessage.getDisplayType() != AiChatMessageDisplayType.toolAiRequest)
                          DisplayAiResult(aiChatMessage: aiChatMessage),
                    ],
                  ),
                ),
              ),
              // IconButton(
              //   icon: const Icon(Icons.check, color: Colors.white),
              //   onPressed: () {
              //     isVisible.value = false;
              //     ref.read(lastAiMessageListenerProvider.notifier).clearState();
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayAiResult extends ConsumerWidget {
  final AiChatMessageModel aiChatMessage;
  const DisplayAiResult({super.key, required this.aiChatMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiChatMessageViewCard(message: aiChatMessage);
  }
}
