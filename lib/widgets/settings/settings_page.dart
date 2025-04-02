import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/common/currency_provider.dart';
import 'package:seren_ai_flutter/common/language_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/speech_to_text/speech_to_text_service_provider.dart';
import 'package:seren_ai_flutter/services/text_to_speech/text_to_speech_notifier.dart';
import 'package:seren_ai_flutter/widgets/debug/debug_mode_provider.dart';
import 'package:seren_ai_flutter/widgets/common/theme_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/widgets/settings/build_info_section.dart';

//
//
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SettingsAccountSection(),
          SettingsAppSection(),
          BuildInfoSection(),
        ],
      ),
    );
  }
}

class SettingsAccountSection extends ConsumerWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(curUserProvider).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.account),
        ),
        user == null
            ? Center(child: Text(AppLocalizations.of(context)!.noAuthUser))
            : Column(
                children: [
                  // TODO p3: Add account editing fields here: name, surname, avatar...
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
                ],
              ),
      ],
    );
  }
}

class SettingsAppSection extends ConsumerWidget {
  const SettingsAppSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final themeMode = ref.watch(themeSNP);
    final language = ref.watch(languageSNP).toUpperCase();
    final isDebugMode = ref.watch(isDebugModeSNP);
    final currency = ref.watch(currencyFormatSNP);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.app),
        ),
        ListTile(
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
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context)!.language,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: DropdownButton<String>(
            value: language,
            onChanged: (String? newLanguage) {
              if (newLanguage != null) {
                ref.read(languageSNP.notifier).setLanguage(newLanguage);
                ref.read(speechToTextServiceProvider).language = newLanguage;
                ref.read(textToSpeechServiceProvider.notifier).language =
                    newLanguage;
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
                child: Text(AppLocalizations.of(context)!.brazilianPortuguese,
                    style: theme.textTheme.bodySmall),
              ),
              DropdownMenuItem(
                value: 'PT_PT',
                child: Text(AppLocalizations.of(context)!.europeanPortuguese,
                    style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
        if (isWebVersion) // budgets are not supported on mobile yet
          ListTile(
            dense: true,
            leading: const Icon(Icons.currency_exchange),
            title: Text(AppLocalizations.of(context)!.currency,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: DropdownButton<String>(
              value: currency.locale,
              onChanged: (String? newCurrencyLocale) {
                if (newCurrencyLocale != null) {
                  ref
                      .read(currencyFormatSNP.notifier)
                      .setCurrency(newCurrencyLocale);
                }
              },
              items: [
                ...AppLocalizations.supportedLocales
                    .where((e) => e.countryCode != null) // avoid unsupported
                    .map((e) => (
                          locale: e.toString(),
                          currencySymbol:
                              NumberFormat.currency(locale: e.toString())
                                  .currencySymbol
                        ))
                    .toSet() // remove duplicated values if there are any
                    .map((e) => DropdownMenuItem(
                          value: e.locale,
                          child: Text(
                            e.currencySymbol,
                            style: theme.textTheme.bodySmall,
                          ),
                        ))
              ],
            ),
          ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.debugMode),
          value: isDebugMode,
          onChanged: (value) {
            ref.read(isDebugModeSNP.notifier).setIsDebugMode(value);
          },
        ),
        // ListTile(
        //   title: Text(AppLocalizations.of(context)!.about),
        // ),
      ],
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
