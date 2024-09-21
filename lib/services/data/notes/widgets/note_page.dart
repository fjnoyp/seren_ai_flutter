import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_read_provider.dart';

class NotePage extends ConsumerWidget {
  final String noteId;

  NotePage({super.key, required this.noteId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteFuture = ref.watch(notesReadProvider).getItem(id: noteId);

    return FutureBuilder<NoteModel?>(
      future: noteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final note = snapshot.data;

        if (note == null) {
          return const Center(child: Text('Note not found'));
        }

        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildNoteDetail('Name', note.name),
                _buildNoteDetail('Author User ID', note.authorUserId),
                _buildNoteDetail('Date', note.date != null ? DateFormat('MM/dd/yyyy').format(note.date!) : 'N/A'),
                _buildNoteDetail('Address', note.address ?? 'N/A'),
                _buildNoteDetail('Description', note.description ?? 'N/A'),
                _buildNoteDetail('Action Required', note.actionRequired ?? 'N/A'),
                _buildNoteDetail('Status', note.status ?? 'N/A'),
                _buildNoteDetail('Parent Note Folder ID', note.parentNoteFolderId ?? 'N/A'),
                _buildNoteDetail('Created At', note.createdAt != null ? DateFormat('MM/dd/yyyy').format(note.createdAt!) : 'N/A'),
                _buildNoteDetail('Updated At', note.updatedAt != null ? DateFormat('MM/dd/yyyy').format(note.updatedAt!) : 'N/A'),
              ],
            ),
        );
      },
    );
  }

  Widget _buildNoteDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

