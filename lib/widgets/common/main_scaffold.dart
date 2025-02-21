import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/user_input_display_widget.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_modal.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: BottomAppBar(
        height: 65,
        padding: EdgeInsets.zero,
        notchMargin: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavItem(
                    context,
                    Icons.grid_view,
                    AppLocalizations.of(context)!.home,
                    () => ref
                        .read(navigationServiceProvider)
                        .navigateTo(AppRoutes.home.name),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PopupMenuButton<String>(
                    offset: const Offset(0, -120),
                    child: _buildNavItem(
                      context,
                      Icons.add_circle_sharp,
                      AppLocalizations.of(context)!.addNew,
                      null,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'task',
                        child: Row(
                          children: [
                            Icon(Icons.task_alt, color: theme.iconTheme.color),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.task),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'note',
                        child: Row(
                          children: [
                            Icon(Icons.note_add, color: theme.iconTheme.color),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.note),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'task':
                          ref.read(taskNavigationServiceProvider).openNewTask();
                          break;
                        case 'note':
                          ref
                              .read(notesNavigationServiceProvider)
                              .openNewNote();
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
            const Spacer(), // Space for FAB
            const Spacer(), // Space for FAB
            const Spacer(), // Space for FAB

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavItem(
                    context,
                    Icons.chat_bubble_outline,
                    AppLocalizations.of(context)!.chat,
                    () => ref
                        .read(navigationServiceProvider)
                        .navigateTo(AppRoutes.aiChats.name),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      VoidCallback? onPressed) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          icon: Icon(icon, color: theme.iconTheme.color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
