import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';

class DeleteNoteButton extends ConsumerWidget {
  final String noteId;

  const DeleteNoteButton({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      // TODO: show a confirmation dialog before deleting
      onPressed: () async {
        final notesDb = ref.watch(notesReadProvider);
        notesDb
            .deleteItem(noteId)
            .then((_) => Navigator.of(context).maybePop());
      },
    );
  }
}
