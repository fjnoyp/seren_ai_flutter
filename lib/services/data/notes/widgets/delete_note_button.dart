import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_service_provider.dart';

class DeleteNoteButton extends ConsumerWidget {
  const DeleteNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      // TODO: show a confirmation dialog before deleting
      onPressed: () async {
        await ref
            .read(curNoteServiceProvider)
            .deleteNote()
            .then((_) => Navigator.of(context).maybePop());
      },
    );
  }
}
