import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_open_modal_button.dart';
import 'package:seren_ai_flutter/widgets/scaffold/drawer_view.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Added import for AppLocalizations
import 'package:seren_ai_flutter/widgets/scaffold/quick_actions_bottom_bar.dart'; // Added import for _QuickActionsBottomAppBar
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_expanded_bottom_bar.dart'; // Added import for UserInputDisplayWidget
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button/mobile_ai_assistant_button.dart'; // Added import for MobileAiAssistantButton

class MobileScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final bool showBottomBar;
  final List<Widget>? actions;
  final bool isAiAssistantExpanded;

  const MobileScaffold({
    required this.title,
    required this.body,
    required this.showBottomBar,
    required this.actions,
    required this.isAiAssistantExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDebugMode = ref.watch(isDebugModeSNP);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: _buildLeadingButtons(context, ref, theme),
        leadingWidth: ref.read(navigationServiceProvider).canPop ? 96 : 48,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        actions: [
          if (!AppConfig.isProdMode)
            const Text(
              'Dev',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          if (isDebugMode) DebugOpenModalButton(),
          ...actions ?? [],
        ],
      ),
      drawer: const DrawerView(),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: body,
      ),
      bottomNavigationBar: showBottomBar
          ? true //isAiAssistantExpanded
              ? const MobileAiAssistantExpandedBottomBar()
              : const QuickActionsBottomAppBar()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          showBottomBar ? const MobileAiAssistantButton() : null,
    );
  }

  Widget _buildLeadingButtons(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return Builder(
      builder: (BuildContext context) {
        return Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: theme.iconTheme.color),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: AppLocalizations.of(context)!.menu,
            ),
            if (ref.read(navigationServiceProvider).canPop)
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                onPressed: () => ref.read(navigationServiceProvider).pop(),
                tooltip: AppLocalizations.of(context)!.back,
              ),
          ],
        );
      },
    );
  }
}
