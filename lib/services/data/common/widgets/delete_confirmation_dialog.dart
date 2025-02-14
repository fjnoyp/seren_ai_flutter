import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';

/// A dialog that confirms the deletion of an item.
/// It returns `true` if the item was deleted.
class DeleteConfirmationDialog extends ConsumerWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
    required this.onDelete,
  });

  final String itemName;
  final FutureOr<void> Function() onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.deleteConfirmationMessage(itemName),
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
            // Unless we always set barrierDismissible to false, we sould not return false here
            // because the dialog will be closed and the cancellation will not be confirmed.
            onPressed: ref.read(navigationServiceProvider).pop,
            child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await onDelete();
              ref.read(navigationServiceProvider).pop(false);
            },
            child: Text(AppLocalizations.of(context)!.delete)),
      ],
    );
  }
}
