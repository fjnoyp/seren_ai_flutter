import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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
    File? tempFile;
    try {
      final pdf = NoteToPdfConverter(widgetRef);
      await pdf.buildPdf();

      final output = await getTemporaryDirectory();
      final name = _state.value!.note.name;
      final path = '${output.path}/${DateTime.now().millisecondsSinceEpoch}_$name.pdf';

      tempFile = File(path);
      final bytes = await pdf.save();
      await tempFile.writeAsBytes(bytes, flush: true);
      
      // Wait for the share operation to complete
      final result = await Share.shareXFiles(
        [XFile(path)],
        subject: name,
      );
      
      // Only proceed with deletion after sharing is complete
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
    } catch (e) {
      print('PDF generation/sharing error: $e');
      // Ensure cleanup happens even if there's an error
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (e) {
          print('Error cleaning up temporary file: $e');
        }
      }
      rethrow;
    }
  }
}
