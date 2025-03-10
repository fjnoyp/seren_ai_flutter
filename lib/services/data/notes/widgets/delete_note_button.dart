import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteNoteButton extends ConsumerWidget {
  const DeleteNoteButton(this.noteId, {super.key, this.showLabelText = false});

  final String noteId;
  final bool showLabelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redColor = Theme.of(context).colorScheme.error;

    return showLabelText
        ? OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: redColor, iconColor: redColor),
            label: Text(AppLocalizations.of(context)!.deleteNote),
            icon: const Icon(Icons.delete),
            onPressed: () async =>
                await _showDeleteConfirmationDialog(context, ref),
          )
        : IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async =>
                await _showDeleteConfirmationDialog(context, ref),
          );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref) async {
    final itemName =
        ref.watch(noteByIdStreamProvider(noteId)).value?.name ?? 'this note';
    await showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          itemName: itemName,
          onDelete: () {
            final noteAttachmentsService =
                ref.read(noteAttachmentsServiceProvider.notifier);
            noteAttachmentsService.deleteAllAttachments(noteId: noteId);

            final notesRepository = ref.read(notesRepositoryProvider);
            ref.read(navigationServiceProvider).pop();
            notesRepository.deleteItem(noteId);
          },
        );
      },
    );
  }
}
