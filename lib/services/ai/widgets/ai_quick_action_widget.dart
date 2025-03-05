import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/ai_quick_actions/models/ai_quick_action.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/ai_chat_text_field.dart';

class AiQuickActionWidget extends ConsumerWidget {
  const AiQuickActionWidget(this.action, {super.key});

  final AiQuickAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        if (isWebVersion) {
          ref.read(isAiAssistantExpandedProvider.notifier).state = true;
          final textController = ref.read(aiChatTextEditingControllerProvider);

          if (action.userInputHint.contains('[') &&
              action.userInputHint.contains(']')) {
            final startSelection = action.userInputHint.indexOf('[');
            final endSelection = action.userInputHint.indexOf(']') -
                1; // -1 to handle brackets removal
            textController.text =
                action.userInputHint.replaceAll('[', '').replaceAll(']', '');

            textController.selection = TextSelection(
              baseOffset: startSelection,
              extentOffset: endSelection,
            );
          } else {
            ref
                .read(aiChatServiceProvider)
                .sendMessageToAi(action.userInputHint);
            textController.clear();
          }
        }
      },
      icon: const Icon(Icons.lightbulb_outline),
      label: Text(action.description),
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(150),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
