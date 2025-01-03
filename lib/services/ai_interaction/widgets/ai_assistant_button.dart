import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/ai_quick_actions_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/models/ai_quick_action.dart';
import 'package:seren_ai_flutter/services/ai_interaction/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_chat_text_field.dart';

class AIAssistantButton extends ConsumerWidget {
  const AIAssistantButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: AppLocalizations.of(context)!.aiAssistant,
      child: GestureDetector(
        onTap: () => ref.read(isAiModalVisibleProvider.notifier).state = true,
        child: Hero(
            tag: 'ai-button',
            child: SizedBox(
                height: 56.0,
                width: 56.0,
                child: SvgPicture.asset('assets/images/AI button.svg'))),
      ),
    );
  }
}

class AIAssistantButtonWithQuickActions extends ConsumerWidget {
  const AIAssistantButtonWithQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...ref.watch(aiQuickActionsServiceProvider).map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _AIQuickActionWidget(action),
              ),
            ),
        const AIAssistantButton(),
      ],
    );
  }
}

class _AIQuickActionWidget extends ConsumerWidget {
  const _AIQuickActionWidget(this.action);

  final AIQuickAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        if (isWebVersion) {
          ref.read(isAiModalVisibleProvider.notifier).state = true;
          final textController = ref.read(aiChatTextEditingControllerProvider);
          textController.text = action.userInputHint;

          if (action.userInputHint.contains('[')) {
            final startSelection = action.userInputHint.indexOf('[');
            final endSelection = action.userInputHint.indexOf(']') + 1;

            textController.selection = TextSelection(
              baseOffset: startSelection,
              extentOffset: endSelection,
            );
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
