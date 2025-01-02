import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seren_ai_flutter/services/ai_interaction/is_ai_modal_visible_provider.dart';

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
