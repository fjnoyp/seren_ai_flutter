import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/models/ai_quick_action.dart';
import 'package:seren_ai_flutter/services/ai_interaction/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_chat_text_field.dart';

class AiQuickActionWidget extends ConsumerWidget {
  const AiQuickActionWidget(this.action, {super.key});

  final AiQuickAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        if (isWebVersion) {
          ref.read(isAiModalVisibleProvider.notifier).state = true;
          final textController = ref.read(aiChatTextEditingControllerProvider);
          // textController.text = action.userInputHint;

          // if (action.userInputHint.contains('[')) {
          //   final startSelection = action.userInputHint.indexOf('[');
          //   final endSelection = action.userInputHint.indexOf(']') + 1;

          //   textController.selection = TextSelection(
          //     baseOffset: startSelection,
          //     extentOffset: endSelection,
          //   );
          // }

          ref.read(aiChatServiceProvider).sendMessageToAi(action.userInputHint);
          textController.clear();
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
