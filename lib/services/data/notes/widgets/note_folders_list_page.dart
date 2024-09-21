// Show the list of note folders that the user has access to 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/notes/cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_folder_notes_list_page.dart';

class NoteFoldersListPage extends ConsumerWidget {
  const NoteFoldersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteFolders = ref.watch(curUserViewableNoteFoldersListenerProvider);

    if (noteFolders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (noteFolders.isEmpty) {
      return const Center(child: Text('No note folders available'));
    }

    return ListView.builder(
      itemCount: noteFolders.length,
      itemBuilder: (context, index) {
        final noteFolder = noteFolders[index];
        return ListTile(
          title: Text(noteFolder.name),
          subtitle: Text(noteFolder.description ?? 'No description'),
          onTap: () {
            openNoteFolderNotes(context, noteFolder.id);
          },
        );
      },
    );
  }

  openNoteFolderNotes(BuildContext context, String noteFolderId) {
    Navigator.pushNamed(context, noteFolderNotesListRoute,
      arguments: {'noteFolderId': noteFolderId});
  }
}
