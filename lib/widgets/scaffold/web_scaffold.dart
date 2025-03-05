import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_modal.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_open_modal_button.dart';
import 'package:seren_ai_flutter/widgets/scaffold/drawer_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final bool showBottomBar;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool isAiAssistantExpanded;

  const WebScaffold({
    required this.title,
    required this.body,
    required this.showBottomBar,
    required this.actions,
    required this.showAppBar,
    required this.isAiAssistantExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDebugMode = ref.watch(isDebugModeSNP);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1200;

        return Row(
          children: [
            if (!isNarrow)
              const SizedBox(
                width: 200,
                child: DrawerView(),
              ),
            Expanded(
              flex: 4,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: showAppBar
                      ? _buildFullAppBar(context, theme, isNarrow, isDebugMode)
                      : _buildMinimalAppBar(context, theme, isNarrow),
                ),
                drawer: isNarrow ? const DrawerView() : null,
                body: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    body,
                    if (showBottomBar && isAiAssistantExpanded)
                      const WebAiAssistantView(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: (showBottomBar && !isAiAssistantExpanded)
          ? const WebAiAssistantButtonWithQuickActions()
          : null,
    );
  }

  AppBar _buildFullAppBar(
      BuildContext context, ThemeData theme, bool isNarrow, bool isDebugMode) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      leading: _buildMenuButton(context, theme),
      elevation: 0,
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
            'DevConfig',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        if (isDebugMode) DebugOpenModalButton(),
        ...actions ?? [],
      ],
    );
  }

  AppBar _buildMinimalAppBar(
      BuildContext context, ThemeData theme, bool isNarrow) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: isNarrow ? _buildMenuButton(context, theme) : null,
    );
  }

  Widget _buildMenuButton(BuildContext context, ThemeData theme) {
    return Builder(
      builder: (context) => IconButton(
        icon: Icon(Icons.menu, color: theme.iconTheme.color),
        onPressed: () => Scaffold.of(context).openDrawer(),
        tooltip: AppLocalizations.of(context)!.menu,
      ),
    );
  }
}
