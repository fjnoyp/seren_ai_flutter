//import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_note_state_provider.dart';
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
  final WidgetRef widgetRef;
  final AsyncValue<JoinedNoteModel?> _state;

  ShareNoteService(this.widgetRef)
      : _state = widgetRef.watch(curNoteStateProvider);

  Future<void> shareNote() async {
    try {
      final pdf = NoteToPdfConverter(widgetRef);
      await pdf.buildPdf();
      final bytes = await pdf.save();
      
      final name = _state.value!.note.name;
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
