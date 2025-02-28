import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/ai/is_ai_modal_visible_provider.dart';
import 'package:seren_ai_flutter/services/ai/widgets/base_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/mobile_ai_assistant_button.dart';
import 'package:seren_ai_flutter/services/ai/widgets/user_input_display_widget.dart';
import 'package:seren_ai_flutter/services/ai/widgets/web_ai_assistant_modal.dart';
import 'package:seren_ai_flutter/services/data/db_setup/app_config.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/users/models/invite_model.dart';
import 'package:seren_ai_flutter/services/data/users/providers/cur_user_invites_service_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_state_modal.dart';
import 'package:seren_ai_flutter/widgets/scaffold/bottom_app_bar_base.dart';
import '../scaffold/drawer_view.dart';
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
    final isAiAssistantExpanded = ref.watch(isAiModalVisibleProvider);

    return PopScope(
      canPop: ref.read(navigationServiceProvider).canPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home.name, (route) => false);
        }
      },
      child: isWebVersion
          ? _WebScaffold(
              title: title,
              body: body,
              showAiAssistant: showAiAssistant,
              actions: actions,
              showAppBar: showAppBar,
              isAiAssistantExpanded: isAiAssistantExpanded,
            )
          : _MobileScaffold(
              title: title,
              body: body,
              showAiAssistant: showAiAssistant,
              actions: actions,
              isAiAssistantExpanded: isAiAssistantExpanded,
            ),
    );
  }
}

class _WebScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final bool showAiAssistant;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool isAiAssistantExpanded;

  const _WebScaffold({
    required this.title,
    required this.body,
    required this.showAiAssistant,
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
        if (isDebugMode) _DebugButton(),
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

class _MobileScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final bool showAiAssistant;
  final List<Widget>? actions;
  final bool isAiAssistantExpanded;

  const _MobileScaffold({
    required this.title,
    required this.body,
    required this.showAiAssistant,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showAiAssistant
          ? isAiAssistantExpanded
              ? null
              : const MobileAiAssistantButton()
          : null,
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
    return BottomAppBarBase(
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
                _buildAddNewButton(context, theme, ref),
              ],
            ),
          ),
          const Spacer(),
          const Spacer(),
          const Spacer(),
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
    );
  }

  Widget _buildAddNewButton(
      BuildContext context, ThemeData theme, WidgetRef ref) {
    return PopupMenuButton<String>(
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
            ref.read(notesNavigationServiceProvider).openNewNote();
            break;
        }
      },
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

class WebAiAssistantButtonWithQuickActions extends ConsumerWidget {
  const WebAiAssistantButtonWithQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseAiAssistantButton(
      onPreClick: () {
        // The base button already sets isAiModalVisibleProvider to true
        // We could add additional actions here if needed
      },
    );
  }
}
