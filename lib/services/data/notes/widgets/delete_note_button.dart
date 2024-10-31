import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';

class DeleteNoteButton extends ConsumerWidget {
  const DeleteNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      // TODO: show a confirmation dialog before deleting
      onPressed: () async {
        final notesDb = ref.watch(notesReadProvider);
        notesDb
            .deleteItem((ref.read(curNoteStateProvider) as LoadedCurNoteState)
                .joinedNote
                .note
                .id)
            .then((_) => Navigator.of(context).maybePop());
      },
    );
  }
}
