import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/widgets/settings/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebSettingsPage extends StatelessWidget {
  const WebSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 20),
            child: Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SettingsAccountSection()),
                VerticalDivider(),
                Expanded(child: SettingsAppSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
