import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_chat_service_provider.dart';

final aiChatTextEditingControllerProvider =
    Provider<TextEditingController>((_) => TextEditingController());

class AiChatTextField extends ConsumerWidget {
  const AiChatTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = ref.watch(aiChatTextEditingControllerProvider);

    return Hero(
      tag: 'ai-chat-text-field',
      child: TextField(
        controller: messageController,
        autofocus: true,
        onSubmitted: (value) {
          if (value.isEmpty) return;
          ref.read(aiChatServiceProvider).sendMessageToAi(value);
          messageController.clear();
        },
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.askAQuestion,
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final message = messageController.text;
              if (message.isNotEmpty) {
                ref.read(aiChatServiceProvider).sendMessageToAi(message);
                messageController.clear();
              }
            },
          ),
        ),
      ),
    );
  }
}
