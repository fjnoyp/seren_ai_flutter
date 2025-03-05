import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/services/ai/ai_quick_actions/ai_quick_actions_service_provider.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/ai_quick_action_widget.dart';

class BaseAiAssistantButton extends ConsumerWidget {
  const BaseAiAssistantButton({
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
            ref.read(isAiAssistantExpandedProvider.notifier).state = true;
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
