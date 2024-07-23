import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/widgets/theme_data.dart';

class DrawerView extends HookWidget {
  const DrawerView({super.key});

  Widget buildRow(String header, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(header, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

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
                  const Text('Settings', style: TextStyle(fontSize: 24)),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      isSettingsView.value = false;
                    },
                  ),
                ] else ...[
                  const Text('Menu', style: TextStyle(fontSize: 24)),
                ],
              ],
            ),
          ),
          if (isSettingsView.value) ...[
            const ListTile(
              title: Text('Account'),
            ),
            Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(curAuthUserProvider);

                if (user == null) {
                  return const Center(child: Text('No Auth User'));
                }

                return Column(children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.email),
                    title: buildRow('Email', user.email ?? 'No email'),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.star),
                    title: buildRow('Subscription', 'Premium'),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      ref.read(curAuthUserProvider.notifier).signOut();
                    },
                  ),
                ]);
              },
            ),
            const ListTile(
              title: Text('App'),
            ),
            Consumer(
              builder: (context, ref, child) {
                final themeMode = ref.watch(themeSNP);
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Color Scheme',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                        child: Text('System', style: theme.textTheme.bodySmall),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light', style: theme.textTheme.bodySmall),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark', style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                );
              },
            ),
            const ListTile(
              title: Text('About'),
            ),
          ] else ...[
            _buildListTile(
              context: context,
              icon: Icons.home,
              title: 'Home',
              onTap: () {
                Navigator.pushNamed(context, homeRoute);
              },
            ),
            _buildListTile(
                context: context,
                icon: Icons.house,
                title: 'Choose Organization',
                onTap: () {
                  Navigator.pushNamed(context, chooseOrgRoute);
                }),
            _buildListTile(
                context: context,
                icon: Icons.people,
                title: 'Org Admin - Manage Org Users',
                onTap: () {
                  Navigator.pushNamed(context, manageOrgUsersRoute);
                }),
            _buildListTile(
              context: context,
              icon: Icons.task,
              title: 'Tasks',
              onTap: () {
                Navigator.pushNamed(context, tasksRoute);
              },
            ),
            _buildListTile(
              context: context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                isSettingsView.value = true;
              },
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
