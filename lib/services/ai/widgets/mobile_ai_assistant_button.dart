// A button that has suggestions on the side ...
// When clicked it puts the bottom ai bar into a different state ... user
// can then choose to use the ai or not ...

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';

class MobileAiAssistantButton extends ConsumerWidget {
  const MobileAiAssistantButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BaseAiAssistantButton();
  }
}
