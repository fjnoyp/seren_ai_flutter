import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/tasks/providers/task_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/widgets/scaffold/bottom_app_bar_base.dart';

class QuickActionsBottomAppBar extends ConsumerWidget {
  const QuickActionsBottomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return BottomAppBarBase(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildNavItem(
              context,
              Icons.grid_view,
              AppLocalizations.of(context)!.home,
              () => ref
                  .read(navigationServiceProvider)
                  .navigateTo(AppRoutes.home.name),
            ),
          ),
          Expanded(
            child: _buildAddNewButton(context, theme, ref),
          ),
          const Spacer(),
          const Spacer(),
          const Spacer(),
          Expanded(
            child: _buildNavItem(
              context,
              Icons.chat_bubble_outline,
              AppLocalizations.of(context)!.chat,
              () => ref
                  .read(navigationServiceProvider)
                  .navigateTo(AppRoutes.aiChats.name),
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
        PopupMenuItem(
          value: 'daily_summary',
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: theme.iconTheme.color),
              const SizedBox(width: 8),
              Text(
                  'Daily Summary'), //AppLocalizations.of(context)!.dailySummary),
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
          case 'daily_summary':
            ref.read(notesNavigationServiceProvider).openDailySummaryNote(
                  DateTime.now(),
                  useExistingIfAvailable: false,
                );
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
