//import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_editing_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/pdf_from_note.dart';
import 'package:share_plus/share_plus.dart';

/// This provider is a family provider because it needs a [WidgetRef] to be created.
final shareNoteServiceProvider = Provider.family<ShareNoteService, WidgetRef>(
  (ref, widgetRef) {
    return ShareNoteService(widgetRef);
  },
);

/// This service needs a [WidgetRef] because the PDF needs a [BuildContext] to get localizations.
class ShareNoteService {
  final WidgetRef ref;

  ShareNoteService(this.ref);

  Future<void> shareNote() async {
    try {
      final pdf = NoteToPdfConverter(ref);
      await pdf.buildPdf();
      final bytes = await pdf.save();

      final curNote = ref.read(curEditingNoteStateProvider).value!.noteModel;

      final name = curNote.name;
      final xFile = XFile.fromData(
        bytes,
        name: '$name.pdf',
        mimeType: 'application/pdf',
      );

      await Share.shareXFiles(
        [xFile],
        subject: name,
      );
    } catch (e) {
      print('PDF generation/sharing error: $e');
      rethrow;
    }
  }
}
