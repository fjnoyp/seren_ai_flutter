import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/shift_tool_methods.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shift_ai_request_result_widgets.dart';

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
                      for (final result in lastAiResults)
                        DisplayAiResult(aiResult: result),
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
  final AiResult aiResult;
  const DisplayAiResult({super.key, required this.aiResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget? content;
    
    if (aiResult is AiChatMessageModel) {
      content = Text((aiResult as AiChatMessageModel).content);
    } else if (aiResult is AiRequestResultModel) {
      if (aiResult is ShiftInfoResultModel) {
        content = ShiftInfoResultWidget(result: aiResult as ShiftInfoResultModel);
      } else if (aiResult is ShiftClockInOutResultModel) {
        content = ShiftClockInOutResultWidget(result: aiResult as ShiftClockInOutResultModel);
      } else {
        content = Text((aiResult as AiRequestResultModel).message);
      }
    }

    bool isToolCall = aiResult is! AiChatMessageModel; 

    return content != null 
        ? Card(            
            color: isToolCall ? 
            Theme.of(context).colorScheme.secondaryContainer : 
            Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Added inner padding
              child: content,
            ),
          )
        : const SizedBox.shrink();
  }
}