import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';

class ConfirmSaveDialog extends ConsumerWidget {
  const ConfirmSaveDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.areYouSure),
        content: Text(AppLocalizations.of(context)!.quitWithoutSaving),
        actions: [
          TextButton(
            onPressed: () => ref.read(navigationServiceProvider).pop(false),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () => ref.read(navigationServiceProvider).pop(true),
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      );
}
