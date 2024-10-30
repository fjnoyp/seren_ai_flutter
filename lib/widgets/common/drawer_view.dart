import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/widgets/common/theme_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawerView extends HookWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isSettingsView = useState(false);
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isSettingsView.value) ...[
                  Text(AppLocalizations.of(context)!.settings,
                      style: const TextStyle(fontSize: 24)),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => isSettingsView.value = false,
                  ),
                ] else ...[
                  Text(AppLocalizations.of(context)!.menu,
                      style: const TextStyle(fontSize: 24)),
                ],
              ],
            ),
          ),
          if (isSettingsView.value) ...[
            ListTile(
              title: Text(AppLocalizations.of(context)!.account),
            ),
            Consumer(
              builder: (context, ref, child) {
                final curAuthUserState = ref.watch(curAuthStateProvider);
                final user = switch (curAuthUserState) {
                  LoggedInAuthState() => curAuthUserState.user,
                  _ => null,
                };

                if (user == null) {
                  return Center(
                      child: Text(AppLocalizations.of(context)!.noAuthUser));
                }

                return Column(children: [
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
                        AppLocalizations.of(context)!.subscription,
                        AppLocalizations.of(context)!.premium),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout),
                    title: Text(AppLocalizations.of(context)!.signOut,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () =>
                        ref.read(curAuthStateProvider.notifier).signOut(),
                  ),
                ]);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.app),
            ),
            Consumer(
              builder: (context, ref, child) {
                final themeMode = ref.watch(themeSNP);
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.color_lens),
                  title: Text(AppLocalizations.of(context)!.colorScheme,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    onChanged: (ThemeMode? newThemeMode) {
                      if (newThemeMode != null) {
                        ref.read(themeSNP.notifier).setTheme(newThemeMode);
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
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.about),
            ),
          ] else ...[
            _buildListTile(
              context: context,
              icon: Icons.home,
              title: AppLocalizations.of(context)!.home,
              onTap: () => Navigator.pushNamed(context, homeRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.house,
              title: AppLocalizations.of(context)!.chooseOrganization,
              onTap: () => Navigator.pushNamed(context, chooseOrgRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.people,
              title: AppLocalizations.of(context)!.orgAdminManageOrgUsers,
              onTap: () => Navigator.pushNamed(context, manageOrgUsersRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.work,
              title: AppLocalizations.of(context)!.projects,
              onTap: () => Navigator.pushNamed(context, projectsRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.task,
              title: AppLocalizations.of(context)!.tasks,
              onTap: () => Navigator.pushNamed(context, tasksRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.square,
              title: AppLocalizations.of(context)!.testSQL,
              onTap: () => Navigator.pushNamed(context, testSQLPageRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.chat,
              title: AppLocalizations.of(context)!.aiChatThreads,
              onTap: () => Navigator.pushNamed(context, aiChatsRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.punch_clock_outlined,
              title: AppLocalizations.of(context)!.shifts,
              onTap: () => Navigator.pushNamed(context, shiftsRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.note_outlined,
              title: AppLocalizations.of(context)!.notes,
              onTap: () => Navigator.pushNamed(context, noteListRoute),
            ),
            _buildListTile(
              context: context,
              icon: Icons.settings,
              title: AppLocalizations.of(context)!.settings,
              onTap: () => isSettingsView.value = true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
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
