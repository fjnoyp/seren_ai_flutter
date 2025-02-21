import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_quick_actions/ai_quick_actions_service_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_quick_action_widget.dart';

class AiAssistantButton extends ConsumerWidget {
  const AiAssistantButton({
    super.key,
    this.size = 56.0,
    this.onPreClick,
  });

  final double size;
  final VoidCallback? onPreClick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: AppLocalizations.of(context)!.aiAssistant,
      child: InkWell(
          onTap: () {
            onPreClick?.call();
            ref.read(isAiModalVisibleProvider.notifier).state = true;
          },
          child:
              // Hero(
              // tag: 'ai-button',
              // child:
              SizedBox(
                  height: size,
                  width: size,
                  child: SvgPicture.asset('assets/images/AI button.svg'))),
      // ),
    );
  }
}

class WebAiAssistantButtonWithQuickActions extends ConsumerWidget {
  const WebAiAssistantButtonWithQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...ref.watch(aiQuickActionsServiceProvider).map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AiQuickActionWidget(action),
              ),
            ),
        const AiAssistantButton(),
      ],
    );
  }
}
