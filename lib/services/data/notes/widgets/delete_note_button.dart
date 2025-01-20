import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_attachments_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';

class DeleteNoteButton extends ConsumerWidget {
  const DeleteNoteButton(this.noteId, {super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final itemName =
            ref.watch(noteByIdStreamProvider(noteId)).value?.name ?? '';
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
                notesRepository
                    .deleteItem(noteId)
                    .then((_) => Navigator.of(context).maybePop());
              },
            );
          },
        );
      },
    );
  }
}
