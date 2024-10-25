import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:seren_ai_flutter/services/data/common/utils/string_extensions.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';

class PdfFromNote extends Document {
  final JoinedNoteModel joinedNote;

  PdfFromNote(this.joinedNote) {
    addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
            children: [
              Text(
                joinedNote.note.name,
                style: const TextStyle(fontSize: 28.0),
              ),
              Text(
                joinedNote.project?.name ?? 'Personal',
                style: const TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Text(
                  'Created by ${joinedNote.authorUser?.email ?? ''} on ${DateFormat('MMM d, yyyy').format(joinedNote.note.createdAt!)}'),
              SizedBox(height: 16.0),
              Text(
                  'Status: ${joinedNote.note.status?.toString().enumToHumanReadable}'),
              SizedBox(height: 12.0),
              Divider(),
              SizedBox(height: 12.0),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Text(joinedNote.note.description ?? ''),
                    SizedBox(height: 16.0),
                    Text(
                      'Address',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Text(joinedNote.note.address ?? ''),
                    SizedBox(height: 16.0),
                    Text(
                      'Action Required',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Text(joinedNote.note.actionRequired ?? ''),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
