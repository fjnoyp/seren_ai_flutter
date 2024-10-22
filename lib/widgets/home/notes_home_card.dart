import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/notes/joined_cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_listener_fam_provider.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class NotesCard extends ConsumerWidget {
  const NotesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: sort list to pick the most recent ones
    final joinedNoteFolders =
        ref.watch(joinedCurUserViewableNoteFoldersListenerProvider);

    // TODO: refactor to use handable error state
    return BaseHomeCard(
      title: "Notes",
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: switch (joinedNoteFolders) {
          null => const CircularProgressIndicator(),
          [] => const Text('No notes'),
          List() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...joinedNoteFolders.take(2).map(
                      (joinedNoteFolder) =>
                          _NoteCardItem(joinedNoteFolder.noteFolder),
                    ),
              ],
            ),
        },
      ),
    );
  }
}

class _NoteCardItem extends ConsumerWidget {
  final NoteFolderModel noteFolder;

  const _NoteCardItem(this.noteFolder);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesListenerFamProvider(noteFolder.id));

    // TODO: refactor to use handable error states
    return switch (notes) {
      null || [] => const SizedBox.shrink(),
      List() => InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            noteFolderNotesListRoute,
            arguments: {'noteFolderId': noteFolder.id},
          ),
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Added inner padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    notes.first.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    noteFolder.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
    };
  }
}
