import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
    required this.onDelete,
  });

  final String itemName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.deleteConfirmationMessage(itemName),
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.delete)),
      ],
    );
  }
}
