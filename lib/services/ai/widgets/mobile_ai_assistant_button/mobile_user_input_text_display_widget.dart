import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_overlay_container.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_overlay_manager.dart';

/// Text input widget that appears as an overlay
class MobileUserInputTextDisplayWidget extends HookWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmit;

  const MobileUserInputTextDisplayWidget({
    super.key,
    required this.controller,
    this.onSubmit,
  });

  /// Show this widget as an overlay
  static void show(
    BuildContext context,
    GlobalKey anchorKey,
    TextEditingController controller,
    VoidCallback? onSubmit,
  ) {
    MobileAiAssistantOverlayManager.show(
      context: context,
      type: AiAssistantOverlayType.textInput,
      anchorKey: anchorKey,
      builder: (context) => MobileUserInputTextDisplayWidget(
        controller: controller,
        onSubmit: onSubmit,
      ),
    );
  }

  /// Hide this overlay
  static void hide() {
    MobileAiAssistantOverlayManager.hide(AiAssistantOverlayType.textInput);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusNode = useMemoized(() => FocusNode(), []);

    useEffect(() {
      return () => focusNode.dispose();
    }, [focusNode]);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: MobileOverlayContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: focusNode.requestFocus,
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your request...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, size: 22),
                    onPressed: () {
                      if (controller.text.isNotEmpty && onSubmit != null) {
                        onSubmit!();
                      }
                    },
                  ),
                ),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.left,
                onSubmitted: (_) {
                  if (onSubmit != null) {
                    onSubmit!();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
