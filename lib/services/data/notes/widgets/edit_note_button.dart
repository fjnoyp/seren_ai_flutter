import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';

class EditNoteButton extends ConsumerWidget {
  const EditNoteButton(this.noteId, {super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => ref.read(notesNavigationServiceProvider).openNote(
        noteId: noteId,
      ),
    );
  }
}
