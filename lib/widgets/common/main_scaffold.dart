import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai_interaction/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/user_input_display_widget.dart';
import 'package:seren_ai_flutter/services/ai_interaction/widgets/web_ai_assistant_modal.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_service_provider.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/common/debug_state_modal.dart';
import 'drawer_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool showAiAssistant;
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
    this.showAiAssistant = true,
    this.actions,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final enableAiBar = true;
    final isAiAssistantExpanded = ref.watch(isAiModalVisibleProvider);

    final theme = Theme.of(context);

    final curUserPendingInvites = ref.watch(curUserInvitesServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final invite in curUserPendingInvites) {
        _showInviteDialog(context, ref, invite);
      }
    });

    final isDebugMode = ref.watch(isDebugModeSNP);

    return PopScope(
      canPop: ref.read(navigationServiceProvider).canPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home.name, (route) => false);
        }
      },
      child: isWebVersion
          ? Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: LayoutBuilder(builder: (context, constraints) {
                final isNarrow =
                    constraints.maxWidth < 1200; // Adjust threshold as needed

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
                        appBar: showAppBar
                            ? AppBar(
                                backgroundColor:
                                    theme.appBarTheme.backgroundColor,
                                automaticallyImplyLeading: isNarrow,
                                leading: isNarrow
                                    ? Builder(
                                        builder: (context) => IconButton(
                                          icon: Icon(Icons.menu,
                                              color: theme.iconTheme.color),
                                          onPressed: () =>
                                              Scaffold.of(context).openDrawer(),
                                          tooltip: AppLocalizations.of(context)!
                                              .menu,
                                        ),
                                      )
                                    : null,
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
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (isDebugMode) _DebugButton(),
                                  ...actions ?? [],
                                ],
                              )
                            : null,
                        drawer: isNarrow ? const DrawerView() : null,
                        body: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            body,
                            if (showAiAssistant && isAiAssistantExpanded)
                              const WebAiAssistantView(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
              floatingActionButton: (showAiAssistant && !isAiAssistantExpanded)
                  ? const WebAiAssistantButtonWithQuickActions()
                  : null,
            )
          : Scaffold(
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
                        if (ref.read(navigationServiceProvider).canPop)
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: theme.iconTheme.color),
                            onPressed:
                                () => // moved logic to navigation service
                                    ref.read(navigationServiceProvider).pop(),
                            tooltip: AppLocalizations.of(context)!.back,
                          ),
                      ],
                    );
                  },
                ),
                leadingWidth: ref.read(navigationServiceProvider).canPop
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
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  if (isDebugMode) _DebugButton(),
                  ...actions ?? [],
                ],
              ),
              drawer: const DrawerView(),
              body: Padding(
                padding: const EdgeInsets.all(0),
                child: body,
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

              bottomNavigationBar: showAiAssistant
                  ? isAiAssistantExpanded
                      ? const UserInputDisplayWidget()
                      : _QuickActionsBottomAppBar()
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: showAiAssistant
                  ? isAiAssistantExpanded
                      ? null
                      : const AiAssistantButton()
                  : null,
            ),
    );
  }

  Future<dynamic> _showInviteDialog(
      BuildContext context, WidgetRef ref, InviteModel invite) {
    final curUserInvitesService =
        ref.read(curUserInvitesServiceProvider.notifier);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.pendingInvite),
        content: Text(AppLocalizations.of(context)!.pendingInviteBody(
            invite.authorUserName,
            invite.orgName,
            invite.orgRole.toHumanReadable(context))),
        actions: [
          TextButton(
            onPressed: () {
              curUserInvitesService.declineInvite(invite);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.decline),
          ),
          FilledButton(
            onPressed: () {
              curUserInvitesService.acceptInvite(invite);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.accept),
          ),
        ],
      ),
    );
  }
}

class _DebugButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.bug_report),
      onPressed: () => _showDebugModal(context, ref),
    );
  }

  void _showDebugModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const DebugStateModal(),
    );
  }
}

class _QuickActionsBottomAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      notchMargin: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.home,
            icon: const Icon(Icons.grid_view),
            onPressed: () => ref
                .read(navigationServiceProvider)
                .navigateToAndRemoveUntil(
                    AppRoutes.home.name, (route) => false),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.createNewTask,
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // Show a bottom modal with buttons to create items (only tasks for now)
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            ref
                                .read(taskNavigationServiceProvider)
                                .openNewTask();
                          },
                          child: Text(AppLocalizations.of(context)!.createTask),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          IconButton(
            tooltip: AppLocalizations.of(context)!.chat,
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => ref
                .read(navigationServiceProvider)
                .navigateTo(AppRoutes.aiChats.name),
          ),
        ],
      ),
    );
  }
}
