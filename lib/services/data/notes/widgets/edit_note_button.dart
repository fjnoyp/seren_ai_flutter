import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';

class EditNoteButton extends ConsumerWidget {
  const EditNoteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // remove self from stack
        Navigator.pop(context);
        openNotePage(context, ref, mode: EditablePageMode.edit);
      },
    );
  }
}
