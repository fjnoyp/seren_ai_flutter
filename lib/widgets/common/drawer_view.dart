import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:seren_ai_flutter/widgets/common/debug_mode_provider.dart';
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
                : Text(AppLocalizations.of(context)!.menu,
                    style: const TextStyle(fontSize: 24)),
          ),
          if (isSettingsView.value) ...[
            ListTile(
              title: Text(AppLocalizations.of(context)!.account),
            ),
            Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(curUserProvider).value;

                if (user == null) {
                  return Center(
                      child: Text(AppLocalizations.of(context)!.noAuthUser));
                }

                return Column(children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.email),
                    title: _BuildRow(
                        AppLocalizations.of(context)!.email, user.email),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.star),
                    title: _BuildRow(AppLocalizations.of(context)!.subscription,
                        AppLocalizations.of(context)!.premium),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout),
                    title: Text(AppLocalizations.of(context)!.signOut,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => ref.read(curUserProvider.notifier).signOut(),
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
            Consumer(
              builder: (context, ref, child) {
                final language = ref.watch(languageSNP).toUpperCase();
                  
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.of(context)!.language,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: DropdownButton<String>(
                    value: language,
                    onChanged: (String? newLanguage) {
                      if (newLanguage != null) {
                        ref.read(languageSNP.notifier).setLanguage(newLanguage);
                        ref.read(speechToTextServiceProvider).language =
                            newLanguage;
                        ref
                            .read(textToSpeechServiceProvider.notifier)
                            .language = newLanguage;
                      }
                    },
                    // these items were removed by commit 588ced3
                    items: [
                      DropdownMenuItem(
                        value: 'EN_US',
                        child: Text(AppLocalizations.of(context)!.english,
                            style: theme.textTheme.bodySmall),
                      ),
                      DropdownMenuItem(
                        value: 'PT_BR',
                        child: Text(
                            AppLocalizations.of(context)!.brazilianPortuguese,
                            style: theme.textTheme.bodySmall),
                      ),
                      DropdownMenuItem(
                        value: 'PT_PT',
                        child: Text(
                            AppLocalizations.of(context)!.europeanPortuguese,
                            style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final isDebugMode = ref.watch(isDebugModeSNP);
                return SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.debugMode),
                  value: isDebugMode,
                  onChanged: (value) {
                    ref.read(isDebugModeSNP.notifier).setIsDebugMode(value);
                  },
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.about),
            ),
          ] else ...[
            _DrawerListTile(
              icon: Icons.home,
              title: AppLocalizations.of(context)!.home,
              onTap: () => Navigator.pushNamed(context, AppRoutes.home.name),
            ),
            _DebugModeListTile(
              icon: Icons.house,
              title: AppLocalizations.of(context)!.chooseOrganization,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.chooseOrg.name),
            ),
            _DebugModeListTile(
              icon: Icons.people,
              title: AppLocalizations.of(context)!.orgAdminManageOrgUsers,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.manageOrgUsers.name),
            ),
            _DrawerListTile(
              icon: Icons.work,
              title: AppLocalizations.of(context)!.projects,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.projects.name),
            ),
            _DrawerListTile(
              icon: Icons.task,
              title: AppLocalizations.of(context)!.tasks,
              onTap: () => Navigator.pushNamed(context, AppRoutes.tasks.name),
            ),
            _DebugModeListTile(
              icon: Icons.square,
              title: AppLocalizations.of(context)!.testSQL,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.testSQLPage.name),
            ),
            _DrawerListTile(
              icon: Icons.chat,
              title: AppLocalizations.of(context)!.aiChatThreads,
              onTap: () => Navigator.pushNamed(context, AppRoutes.aiChats.name),
            ),
            _DrawerListTile(
              icon: Icons.punch_clock_outlined,
              title: AppLocalizations.of(context)!.shifts,
              onTap: () => Navigator.pushNamed(context, AppRoutes.shifts.name),
            ),
            _DrawerListTile(
              icon: Icons.note_outlined,
              title: AppLocalizations.of(context)!.notes,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.noteList.name),
            ),
            _DrawerListTile(
              icon: Icons.bar_chart,
              title: 'Charts', //AppLocalizations.of(context)!.charts,
              onTap: () => Navigator.pushNamed(context, AppRoutes.charts.name),
            ),
            _DrawerListTile(
              icon: Icons.settings,
              title: AppLocalizations.of(context)!.settings,
              onTap: () => isSettingsView.value = true,
            ),
          ],
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
