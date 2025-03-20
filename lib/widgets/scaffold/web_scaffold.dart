import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_modal.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/widgets/search/global_search_text_field.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_open_modal_button.dart';
import 'package:seren_ai_flutter/widgets/scaffold/drawer_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final bool showBottomBar;
  final List<Widget>? actions;
  final bool isAiAssistantExpanded;

  const WebScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.showBottomBar,
    required this.actions,
    required this.isAiAssistantExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  child: _MinimalAppBar(isNarrow: isNarrow),
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
}

// class _FullAppBar extends AppBar {
//   _FullAppBar({
//     required String title,
//     required List<Widget> actions,
//     required ThemeData theme,
//     required BuildContext context,
//     required bool isDebugMode,
//     required bool isNarrow,
//   }) : super(
//           backgroundColor: theme.appBarTheme.backgroundColor,
//           leading: isNarrow ? _MenuButton() : null,
//           elevation: 0,
//           title: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               title,
//               style: theme.appBarTheme.titleTextStyle,
//             ),
//           ),
//           actions: [
//             if (!AppConfig.isProdMode)
//               const Text(
//                 'DevConfig',
//                 style:
//                     TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//               ),
//             if (isDebugMode) DebugOpenModalButton(),
//             ...actions,
//           ],
//         );
// }

class _MinimalAppBar extends ConsumerWidget {
  const _MinimalAppBar({required this.isNarrow});

  final bool isNarrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(isDebugModeSNP);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: isNarrow ? _MenuButton() : null,
      centerTitle: true,
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: const GlobalSearchTextField(),
      ),
      actions: [
        if (!AppConfig.isProdMode)
          const Text(
            'DevConfig',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        if (isDebugMode) DebugOpenModalButton(),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold.of(context).isDrawerOpen
        ? const SizedBox.shrink()
        : IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: AppLocalizations.of(context)!.menu,
          );
  }
}
