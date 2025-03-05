import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
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

  // This is a temporary solution to hide the app bar on the project page.
  // The future goal is not to show the app bar on any web pages at all,
  // but this is a quick fix to make the project page look better for now.
  // TODO p2: remove this once we adjust the web layout on all pages
  final bool showAppBar;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.showBottomBar = true,
    this.actions,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAiAssistantExpanded = ref.watch(isAiAssistantExpandedProvider);

    return PopScope(
      canPop: ref.read(navigationServiceProvider).canPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home.name, (route) => false);
        }
      },
      child: isWebVersion
          ? WebScaffold(
              title: title,
              body: body,
              showBottomBar: showBottomBar,
              actions: actions,
              showAppBar: showAppBar,
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
