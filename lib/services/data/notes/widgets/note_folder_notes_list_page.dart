import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';


class NoteFolderNotesListPage extends ConsumerWidget {
  final String noteFolderId;

  NoteFolderNotesListPage({super.key, required this.noteFolderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO p5: inefficient, should get note_folder directly
    final noteFolders = ref.watch(curUserViewableNoteFoldersListenerProvider);
    final curNoteFolder =
        noteFolders?.firstWhere((folder) => folder.id == noteFolderId);

    final notes = ref.watch(notesListenerFamProvider(noteFolderId));

    if (curNoteFolder == null || notes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _displayNoteFolder(curNoteFolder),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _buildNoteItem(context, note);
              },
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // TODO p0: create new note and open 
                },
                child: const Text('Create New Note'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _displayNoteFolder(NoteFolderModel curNoteFolder) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Folder: ${curNoteFolder.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (curNoteFolder.description != null)
              Text('Description: ${curNoteFolder.description}'),
            Text('Created At: ${curNoteFolder.createdAt != null ? _dayFormat.format(curNoteFolder.createdAt!) : ''}'),
          ],
        ),
      ),
    );
  }

  final DateFormat _dayFormat = DateFormat('MM/dd/yyyy');
  Widget _buildNoteItem(BuildContext context, NoteModel note) {    
    return ListTile(
      title: Text(note.name),
      subtitle: Text(
        note.description ?? '',
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        note.createdAt != null ? _dayFormat.format(note.createdAt!) : '',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        //openNotePage(context, note.id);
      },
    );
  }
}

