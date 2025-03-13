import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_role_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/cur_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_avatar_image.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawerView extends ConsumerWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(curUserProvider).value;
    final isDebugMode = ref.watch(isDebugModeSNP);
    final curRoute = ref.watch(currentRouteProvider);

    final curOrgId = ref.watch(curSelectedOrgIdNotifierProvider);
    final curOrg = curOrgId != null
        ? ref
            .watch(curUserOrgsProvider)
            .valueOrNull
            ?.firstWhere((org) => org.id == curOrgId)
        : null;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: InkWell(
              onTap:
                  ref.watch(curUserOrgRoleProvider).valueOrNull == OrgRole.admin
                      ? () => openOrgPage(context)
                      : null,
              child: Row(
                children: [
                  if (curOrg != null) ...[
                    OrgAvatarImage(org: curOrg),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      curOrg?.name ?? AppLocalizations.of(context)!.menu,
                      style: const TextStyle(fontSize: 24),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: AppLocalizations.of(context)!.chooseOrganization,
                    color: Theme.of(context).colorScheme.outline,
                    onPressed: () => ref
                        .read(navigationServiceProvider)
                        .navigateTo(AppRoutes.chooseOrg.name),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _DrawerListTile(
                  icon: Icons.home,
                  title: AppLocalizations.of(context)!.home,
                  onTap: () => ref
                      .read(navigationServiceProvider)
                      .navigateTo(AppRoutes.home.name),
                  isSelected: curRoute == AppRoutes.home.name,
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final projects = ref
                            .watch(curUserViewableProjectsProvider)
                            .valueOrNull ??
                        <ProjectModel>[];

                    return _ExpandableListTile(
                      icon: Icons.work,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      title: AppLocalizations.of(context)!.projects,
                      options: projects,
                      optionToString: (project) => project.name,
                      onTapOption: (project) => ref
                          .read(projectNavigationServiceProvider)
                          .openProjectPage(projectId: project.id),
                      onTapAddButton: () => ref
                          .read(projectNavigationServiceProvider)
                          .openProjectPage(mode: EditablePageMode.create),
                    );
                  },
                ),
                // if (!isWebVersion || isDebugMode)
                //   _DrawerListTile(
                //     icon: Icons.task,
                //     title: AppLocalizations.of(context)!.tasks,
                //     onTap: () => ref
                //         .read(navigationServiceProvider)
                //         .navigateTo(AppRoutes.tasks.name),
                //    isSelected: curRoute == AppRoutes.tasks.name,
                //   ),
                _DebugModeListTile(
                  icon: Icons.code,
                  title: AppLocalizations.of(context)!.testSQL,
                  onTap: () => ref
                      .read(navigationServiceProvider)
                      .navigateTo(AppRoutes.testSQLPage.name),
                  selected: curRoute == AppRoutes.testSQLPage.name,
                ),
                _DebugModeListTile(
                  icon: Icons.air,
                  title: "Test AI",
                  onTap: () => ref
                      .read(navigationServiceProvider)
                      .navigateTo(AppRoutes.testAiPage.name),
                  selected: curRoute == AppRoutes.testAiPage.name,
                ),
                _DrawerListTile(
                  icon: Icons.chat,
                  title: AppLocalizations.of(context)!.aiChatThreads,
                  onTap: () => ref
                      .read(navigationServiceProvider)
                      .navigateTo(AppRoutes.aiChats.name),
                  isSelected: curRoute == AppRoutes.aiChats.name,
                ),
                _DrawerListTile(
                  icon: Icons.punch_clock_outlined,
                  title: AppLocalizations.of(context)!.shifts,
                  onTap: () => ref
                      .read(navigationServiceProvider)
                      .navigateTo(AppRoutes.shifts.name),
                  isSelected: curRoute == AppRoutes.shifts.name,
                ),
                _DebugModeListTile(
                  icon: Icons.table_chart_outlined,
                  title: 'Gantt Chart',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.taskGantt.name),
                  selected: curRoute == AppRoutes.taskGantt.name,
                ),
                if (!isWebVersion || isDebugMode)
                  _DrawerListTile(
                    icon: Icons.note_outlined,
                    title: AppLocalizations.of(context)!.notes,
                    onTap: () => ref
                        .read(navigationServiceProvider)
                        .navigateTo(AppRoutes.noteList.name),
                    isSelected: curRoute == AppRoutes.noteList.name,
                  ),
                _DrawerListTile(
                  icon: Icons.notifications,
                  title: AppLocalizations.of(context)!.notifications,
                  onTap: () => ref
                      .read(navigationServiceProvider)
                      .navigateTo(AppRoutes.notifications.name),
                  isSelected: curRoute == AppRoutes.notifications.name,
                ),
              ],
            ),
          ),
          const Divider(),
          if (user != null)
            ListTile(
              onTap: () => ref
                  .read(navigationServiceProvider)
                  .navigateTo(AppRoutes.settings.name),
              leading: UserAvatar(user, radius: 16),
              title: Text(
                '${user.firstName} ${user.lastName}',
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
              trailing: Tooltip(
                message: AppLocalizations.of(context)!.signOut,
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(curUserProvider.notifier).signOut(),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class _DrawerListTile extends ListTile {
  _DrawerListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) : super(
          dense: true,
          leading: Icon(icon),
          selected: isSelected,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: onTap,
        );
}

class _DebugModeListTile extends ConsumerWidget {
  const _DebugModeListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.selected,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(isDebugModeSNP);
    return isDebugMode
        ? _DrawerListTile(
            icon: icon,
            title: title,
            onTap: onTap,
            isSelected: selected,
          )
        : const SizedBox.shrink();
  }
}

// class _AdminOnlyListTile extends ConsumerWidget {
//   const _AdminOnlyListTile({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isAdmin =
//         ref.watch(curUserOrgRoleProvider).valueOrNull == OrgRole.admin;
//     return isAdmin
//         ? _DrawerListTile(
//             icon: icon,
//             title: title,
//             onTap: onTap,
//           )
//         : const SizedBox.shrink();
//   }
// }

class _ExpandableListTile<T extends Object> extends ExpansionTile {
  _ExpandableListTile({
    required IconData icon,
    required super.iconColor,
    required String title,
    required List<T> options,
    required String Function(T option) optionToString,
    required void Function(T option) onTapOption,
    VoidCallback? onTapAddButton,
  }) : super(
          dense: true,
          leading: Icon(icon),
          collapsedIconColor: iconColor,
          initiallyExpanded: true,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          textColor: null,
          collapsedTextColor: null,
          backgroundColor: Colors.transparent,
          children: options
              .map((option) => ListTile(
                    dense: true,
                    leading: const SizedBox.shrink(),
                    title: Text(optionToString(option)),
                    onTap: () => onTapOption(option),
                  ))
              .toList(),
          trailing: onTapAddButton != null
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onTapAddButton,
                )
              : null,
        );
}
