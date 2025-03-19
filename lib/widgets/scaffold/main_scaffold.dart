import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_assistant_expanded_provider.dart';
import 'package:seren_ai_flutter/widgets/scaffold/mobile_scaffold.dart';
import 'package:seren_ai_flutter/widgets/scaffold/web_scaffold.dart';

class MainScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool showBottomBar;
  final List<Widget>? actions;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.showBottomBar = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAiAssistantExpanded = ref.watch(isAiAssistantExpandedProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        // call the pop method of the navigation service provider
        await ref.read(navigationServiceProvider).pop();
      },
      child: isWebVersion
          ? WebScaffold(
              title: title,
              body: body,
              showBottomBar: showBottomBar,
              actions: actions,
              isAiAssistantExpanded: isAiAssistantExpanded,
            )
          : MobileScaffold(
              title: title,
              body: body,
              showBottomBar: showBottomBar,
              actions: actions,
              isAiAssistantExpanded: isAiAssistantExpanded,
            ),
    );
  }
}
