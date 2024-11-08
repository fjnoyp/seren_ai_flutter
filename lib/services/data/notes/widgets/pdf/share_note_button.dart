import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/share_note_service_provider.dart';

class ShareNoteButton extends ConsumerWidget {
  const ShareNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: ref.read(shareNoteServiceProvider(ref)).shareNote,
    );
  }
}
