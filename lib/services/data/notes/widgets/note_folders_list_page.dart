// Show the list of note folders that the user has access to

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/constants.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/joined_cur_user_viewable_note_folders_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_folder_model.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_folder_notes_list_page.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_folder_page.dart';

class NoteFoldersListPage extends ConsumerWidget {
  const NoteFoldersListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinedNoteFolders = ref.watch(joinedCurUserViewableNoteFoldersListenerProvider);

    if (joinedNoteFolders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (joinedNoteFolders.isEmpty) {
      return const Center(child: Text('No note folders available'));
    }

    return Column(children: [
      Expanded(
        child: ListView.builder(
          itemCount: joinedNoteFolders.length,
        itemBuilder: (context, index) {
          final joinedNoteFolder = joinedNoteFolders[index];
          final noteFolder = joinedNoteFolder.noteFolder;
          final project = joinedNoteFolder.project;          

          return ListTile(
            title: Text(noteFolder.name),
            subtitle: Text(noteFolder.description ?? 'No description'),
            onTap: () {
              openNoteFolderNotes(context, noteFolder.id);
            },
            trailing: project != null ? Text(project.name) : null,
          );
        },
      )
      ),
      CreateItemBottomButton(
        onPressed: () async => await openNoteFolderPage(context, ref, mode: EditablePageMode.create),
        buttonText: 'Create New Note Folder',
      ),
    ]);
  }

  openNoteFolderNotes(BuildContext context, String noteFolderId) {
    Navigator.pushNamed(context, noteFolderNotesListRoute,
        arguments: {'noteFolderId': noteFolderId});
  }
}
