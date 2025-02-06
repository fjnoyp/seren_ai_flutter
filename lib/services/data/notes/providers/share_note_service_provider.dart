//import 'dart:io';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/note_to_pdf_converter.dart';
import 'package:share_plus/share_plus.dart';

/// This provider is a family provider because it needs a [WidgetRef] to be created.
final shareNoteServiceProvider =
    Provider.autoDispose.family<ShareNoteService, WidgetRef>(
  (ref, widgetRef) {
    return ShareNoteService(widgetRef);
  },
);

/// This service needs a [WidgetRef] because it needs both:
/// - to access the [notesRepositoryProvider]
/// - to get a [BuildContext] for the pdf to get localizations.
class ShareNoteService {
  final WidgetRef ref;

  ShareNoteService(this.ref);

  Future<void> shareNote(String noteId) async {
    try {
      final note = await ref.read(notesRepositoryProvider).getById(noteId);
      if (note == null) throw Exception('Note not found');

      final pdf = NoteToPdfConverter(ref, note);
      await pdf.buildPdf();
      final bytes = await pdf.save();

      final xFile = XFile.fromData(
        bytes,
        name: '${note.name}.pdf',
        mimeType: 'application/pdf',
      );

      await Share.shareXFiles(
        [xFile],
        subject: note.name,
      );
    } catch (e) {
      log('PDF generation/sharing error: $e');
      rethrow;
    }
  }
}
