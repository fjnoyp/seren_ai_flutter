import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/models/user_org_role_model.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_org_dependency_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_org_roles_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_user_orgs_provider.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/cur_org_page.dart';
import 'package:seren_ai_flutter/services/data/orgs/widgets/org_avatar_image.dart';
import 'package:seren_ai_flutter/services/data/projects/models/project_model.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/projects/widgets/project_page.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/common/theme_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawerView extends HookConsumerWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSettingsView = useState(false);
    final theme = Theme.of(context);

    final user = ref.watch(curUserProvider).value;
    final themeMode = ref.watch(themeSNP);
    final language = ref.watch(languageSNP).toUpperCase();
    final isDebugMode = ref.watch(isDebugModeSNP);

    final curOrgId = ref.watch(curOrgIdProvider);
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
            child: isSettingsView.value
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => isSettingsView.value = false,
                      ),
                      Text(AppLocalizations.of(context)!.settings,
                          style: const TextStyle(fontSize: 24)),
                    ],
                  )
                : Row(
                    children: [
                      if (curOrg != null) ...[
                        OrgAvatarImage(org: curOrg),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Text(
                            curOrg?.name ?? AppLocalizations.of(context)!.menu,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: ListView(
              children: isSettingsView.value
                  ? [
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.account),
                      ),
                      user == null
                          ? Center(
                              child: Text(
                                  AppLocalizations.of(context)!.noAuthUser))
                          : Column(
                              children: [
                                ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.email),
                                  title: _BuildRow(
                                      AppLocalizations.of(context)!.email,
                                      user.email),
                                ),
                                ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.star),
                                  title: _BuildRow(
                                      AppLocalizations.of(context)!
                                          .subscription,
                                      AppLocalizations.of(context)!.premium),
                                ),
                                ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.logout),
                                  title: Text(
                                      AppLocalizations.of(context)!.signOut,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onTap: () => ref
                                      .read(curUserProvider.notifier)
                                      .signOut(),
                                ),
                              ],
                            ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.app),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.color_lens),
                        title: Text(AppLocalizations.of(context)!.colorScheme,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: DropdownButton<ThemeMode>(
                          value: themeMode,
                          onChanged: (ThemeMode? newThemeMode) {
                            if (newThemeMode != null) {
                              ref
                                  .read(themeSNP.notifier)
                                  .setTheme(newThemeMode);
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(AppLocalizations.of(context)!.system,
                                  style: theme.textTheme.bodySmall),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(AppLocalizations.of(context)!.light,
                                  style: theme.textTheme.bodySmall),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(AppLocalizations.of(context)!.dark,
                                  style: theme.textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.language),
                        title: Text(AppLocalizations.of(context)!.language,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: DropdownButton<String>(
                          value: language,
                          onChanged: (String? newLanguage) {
                            if (newLanguage != null) {
                              ref
                                  .read(languageSNP.notifier)
                                  .setLanguage(newLanguage);
                              ref.read(speechToTextServiceProvider).language =
                                  newLanguage;
                              ref
                                  .read(textToSpeechServiceProvider.notifier)
                                  .language = newLanguage;
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'EN_US',
                              child: Text(AppLocalizations.of(context)!.english,
                                  style: theme.textTheme.bodySmall),
                            ),
                            DropdownMenuItem(
                              value: 'PT_BR',
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .brazilianPortuguese,
                                  style: theme.textTheme.bodySmall),
                            ),
                            DropdownMenuItem(
                              value: 'PT_PT',
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .europeanPortuguese,
                                  style: theme.textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.debugMode),
                        value: isDebugMode,
                        onChanged: (value) {
                          ref
                              .read(isDebugModeSNP.notifier)
                              .setIsDebugMode(value);
                        },
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.about),
                      ),
                    ]
                  : [
                      _DrawerListTile(
                        icon: Icons.home,
                        title: AppLocalizations.of(context)!.home,
                        onTap: () =>
                            ref
                            .read(navigationServiceProvider)
                            .navigateTo(AppRoutes.home.name),
                      ),
                      _DebugModeListTile(
                        icon: Icons.house,
                        title: AppLocalizations.of(context)!.chooseOrganization,
                        onTap: () => ref
                            .read(navigationServiceProvider)
                            .navigateTo(AppRoutes.chooseOrg.name),
                      ),
                      _AdminOnlyListTile(
                        icon: Icons.business,
                        title: AppLocalizations.of(context)!.organization,
                        onTap: () => openOrgPage(context),
                      ),
                      isWebVersion
                          ? Consumer(
                              builder: (context, ref, child) {
                                final projects = ref
                                        .watch(curUserViewableProjectsProvider)
                                        .valueOrNull ??
                                    <ProjectModel>[];

                                return _ExpandableListTile(
                                  icon: Icons.work,
                                  title: AppLocalizations.of(context)!.projects,
                                  options: projects,
                                  optionToString: (project) => project.name,
                                  onTapOption: (project) => openProjectPage(
                                      ref, context,
                                      project: project),
                                  onTapAddButton: () =>
                                      openCreateProjectPage(ref, context),
                                );
                              },
                            )
                          : _DrawerListTile(
                              icon: Icons.work,
                              title: AppLocalizations.of(context)!.projects,
                              onTap: () => ref
                                  .read(navigationServiceProvider)
                                  .navigateTo(AppRoutes.projects.name),
                            ),
                      if (!isWebVersion || isDebugMode)
                        _DrawerListTile(
                          icon: Icons.task,
                          title: AppLocalizations.of(context)!.tasks,
                          onTap: () => ref
                              .read(navigationServiceProvider)
                              .navigateTo(AppRoutes.tasks.name),
                        ),
                      _DebugModeListTile(
                        icon: Icons.square,
                        title: AppLocalizations.of(context)!.testSQL,
                        onTap: () => ref
                            .read(navigationServiceProvider)
                            .navigateTo(AppRoutes.testSQLPage.name),
                      ),
                      _DrawerListTile(
                        icon: Icons.chat,
                        title: AppLocalizations.of(context)!.aiChatThreads,
                        onTap: () => ref
                            .read(navigationServiceProvider)
                            .navigateTo(AppRoutes.aiChats.name),
                      ),
                      _DrawerListTile(
                        icon: Icons.punch_clock_outlined,
                        title: AppLocalizations.of(context)!.shifts,
                        onTap: () =>
                            ref
                            .read(navigationServiceProvider)
                            .navigateTo(AppRoutes.shifts.name),
                      ),
                      if (!isWebVersion || isDebugMode)
                        _DrawerListTile(
                          icon: Icons.note_outlined,
                          title: AppLocalizations.of(context)!.notes,
                          onTap: () => ref
                              .read(navigationServiceProvider)
                              .navigateTo(AppRoutes.noteList.name),
                        ),
                      _DrawerListTile(
                        icon: Icons.settings,
                        title: AppLocalizations.of(context)!.settings,
                        onTap: () => isSettingsView.value = true,
                      ),
                    ],
            ),
          ),
          const Divider(),
          if (user != null)
            ListTile(
              leading: UserAvatar(user, radius: 16),
              title: Text('${user.firstName} ${user.lastName}'),
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

class _BuildRow extends Row {
  _BuildRow(String header, String value)
      : super(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(header, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        );
}

class _DrawerListTile extends ListTile {
  _DrawerListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) : super(
          dense: true,
          leading: Icon(icon),
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
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(isDebugModeSNP);
    return isDebugMode
        ? _DrawerListTile(
            icon: icon,
            title: title,
            onTap: onTap,
          )
        : const SizedBox.shrink();
  }
}

class _AdminOnlyListTile extends ConsumerWidget {
  const _AdminOnlyListTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin =
        ref.watch(curUserOrgRoleProvider).valueOrNull == OrgRole.admin;
    return isAdmin
        ? _DrawerListTile(
            icon: icon,
            title: title,
            onTap: onTap,
          )
        : const SizedBox.shrink();
  }
}

class _ExpandableListTile<T extends Object> extends ExpansionTile {
  _ExpandableListTile({
    required IconData icon,
    required String title,
    required List<T> options,
    required String Function(T option) optionToString,
    required void Function(T option) onTapOption,
    VoidCallback? onTapAddButton,
  }) : super(
          dense: true,
          leading: Icon(icon),
          initiallyExpanded: true,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
