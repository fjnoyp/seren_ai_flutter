import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/delete_confirmation_dialog.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_service_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_state_provider.dart';

class DeleteNoteButton extends ConsumerWidget {
  const DeleteNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        final itemName = ref.read(curNoteStateProvider).value!.note.name;
        showDialog(
          context: context,
          builder: (context) => DeleteConfirmationDialog(
            itemName: itemName,
            onDelete: () async {
              await ref
                  .read(curNoteServiceProvider)
                  .deleteNote()
                  .then((_) => ref.read(navigationServiceProvider).pop());
            },
          ),
        );
      },
    );
  }
}
