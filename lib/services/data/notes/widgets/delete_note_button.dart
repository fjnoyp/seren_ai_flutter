import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_editing_note_state_provider.dart';

class DeleteNoteButton extends ConsumerWidget {
  const DeleteNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      // TODO p2: show a confirmation dialog before deleting
      // TODO p3: should take noteid instead of implicilty relying on note editing state provider
      onPressed: () async {
        await ref
            .read(curEditingNoteStateProvider.notifier)
            .deleteNote()
            .then((_) => Navigator.of(context).maybePop());
      },
    );
  }
}
