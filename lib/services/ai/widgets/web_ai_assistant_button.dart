import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/services/ai/ai_quick_actions/ai_quick_actions_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/ai_quick_action_widget.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';

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
        const BaseAiAssistantButton(),
      ],
    );
  }
}
