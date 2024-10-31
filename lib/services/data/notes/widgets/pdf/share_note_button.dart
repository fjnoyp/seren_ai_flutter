import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_state_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/ui_state/cur_note_states.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/pdf/pdf_from_note.dart';
import 'package:share_plus/share_plus.dart';

class ShareNoteButton extends ConsumerWidget {
  const ShareNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () async {
        final pdf = NoteToPdfConverter(ref);
        // We need to call buildPdf here because the function is async (due to images loading)
        await pdf.buildPdf();

        final output = await getTemporaryDirectory();
        final name = (ref.watch(curNoteStateProvider) as LoadedCurNoteState)
            .joinedNote
            .note
            .name;
        final path = '${output.path}/$name.pdf';

        final file = File(path);
        await file.writeAsBytes(await pdf.save());

        await Share.shareXFiles([XFile(path)]);
        file.delete();
      },
    );
  }
}
