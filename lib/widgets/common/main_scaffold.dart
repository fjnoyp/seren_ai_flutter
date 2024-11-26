import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/user_input_display_widget.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/widgets/common/is_show_save_dialog_on_pop_provider.dart';
import 'drawer_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScaffold extends HookConsumerWidget {
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
    // final enableAiBar = true;
    final isAiAssistantExpanded = useState(false);

    final theme = Theme.of(context);

    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home.name, (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: Builder(
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
                  // TODO p2: back button is in a weird location. we should only conditionally show back button
                  if (Navigator.of(context).canPop())
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: theme.iconTheme.color),
                      onPressed: () async {
                        final canSave = ref.read(isShowSaveDialogOnPopProvider);

                        if (!canSave) {
                          Navigator.of(context).pop(true);
                        } 
                        // If can save - show dialog to confirm save
                        else {
                          final shouldSave = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.areYouSure),
                              content: Text(
                                  AppLocalizations.of(context)!.quitWithoutSaving),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(AppLocalizations.of(context)!.no),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(AppLocalizations.of(context)!.yes),
                                ),
                              ],
                            ),
                          );   
                          if (shouldSave ?? false) {
                            ref.read(isShowSaveDialogOnPopProvider.notifier).reset();
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      tooltip: AppLocalizations.of(context)!.back,
                    ),
                ],
              );
            },
          ),
          leadingWidth: Navigator.of(context).canPop()
              ? 96
              : 48, // Adjust width based on whether back button is shown

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
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ...actions ?? [],
          ],
        ),
        drawer: const DrawerView(),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: body,
            ),
          ],
        ),

        /*
        floatingActionButton: enableAiBar ? Consumer(
          builder: (context, ref, child) {
            return FloatingActionButton(
              onPressed: () {
                ref.read(aiOrchestratorProvider).testMove(context);
              },
              child: Icon(Icons.pets),
            );
          },
        ) : null,
        */

        bottomNavigationBar: showBottomBar
            ? isAiAssistantExpanded.value
                ? UserInputDisplayWidget(isAiAssistantExpanded)
                : BottomAppBar(
                    notchMargin: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.home,
                          icon: const Icon(Icons.grid_view),
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  AppRoutes.home.name, (route) => false),
                        ),
                        const SizedBox.shrink(),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.chat,
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.aiChats.name),
                        ),
                      ],
                    ),
                  )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: showBottomBar
            ? isAiAssistantExpanded.value
                ? null
                : Tooltip(
                    message: AppLocalizations.of(context)!.aiAssistant,
                    child: GestureDetector(
                      onTap: () => isAiAssistantExpanded.value = true,
                      child: Hero(
                          tag: 'ai-button',
                          child: SizedBox(
                              height: 56.0,
                              child: SvgPicture.asset(
                                  'assets/images/AI button.svg'))),
                    ),
                  )
            : null,
      ),
    );
  }
}
