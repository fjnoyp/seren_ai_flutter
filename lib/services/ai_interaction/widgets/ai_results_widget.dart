import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/ai_request_executor.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/ai_chats/models/ai_chat_message_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/shift_tool_methods.dart';
import 'package:seren_ai_flutter/services/data/shifts/widgets/shift_ai_request_result_widgets.dart';

class AiResultsWidget extends HookConsumerWidget {
  const AiResultsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {    
    final lastAiMessages = ref.watch(lastAiMessageListenerProvider);    
    final isVisible = useState(lastAiMessages.isNotEmpty);

    useEffect(() {
      if (lastAiMessages.isEmpty) {
        isVisible.value = false;
      } else {
        isVisible.value = true;
      }
      return null;
    }, [lastAiMessages]);

    return Visibility(
      visible: isVisible.value, 
      child: Card(
        color: Theme.of(context).colorScheme.primary,
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
                    children: [
                      for (final message in lastAiMessages)
                        DisplayAiResult(aiResult: message),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  isVisible.value = false;
                  ref.read(lastAiMessageListenerProvider.notifier).clearState();
                },
              ),
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
    if (aiResult is AiChatMessageModel) {
      return Text((aiResult as AiChatMessageModel).content);
    } else if (aiResult is AiRequestResult) {
      if (aiResult is ShiftInfoResult) {
        return ShiftInfoResultWidget(result: aiResult as ShiftInfoResult);
      } else if (aiResult is ShiftClockInOutResult) {
        return ShiftClockInOutResultWidget(result: aiResult as ShiftClockInOutResult);
      } else {
        return Text((aiResult as AiRequestResult).message);
      }
    }

    return const SizedBox.shrink(); // Fallback empty widget
  }
}