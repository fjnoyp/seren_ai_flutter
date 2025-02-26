import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editable_page_mode_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/cur_selected_note_id_notifier_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/delete_note_button.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/form/new_note_selection_fields.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_attachments/note_attachment_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final log = Logger('NotePage');

/// For creating / editing a note
class NotePage extends HookConsumerWidget {
  final EditablePageMode mode;

  const NotePage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyFocusNode = useFocusNode();
    final titleFocusNode = useFocusNode();

    // Only auto-focus the title when creating a new note
    useEffect(() {
      if (mode == EditablePageMode.create) {
        titleFocusNode.requestFocus();
      }
      return null;
    }, []);

    final noteId = ref.watch(curSelectedNoteIdNotifierProvider);
    if (noteId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationServiceProvider).pop(true);
      });
      return const Center(child: Text('No note selected'));
    }

    final note = ref.watch(noteByIdStreamProvider(noteId));

    return SingleChildScrollView(
      child: Column(
        children: [
          NewNoteTitleField(
            noteId: noteId,
            focusNode: titleFocusNode,
            onSubmitted: () {
              // When user hits return in title, move focus to body
              bodyFocusNode.requestFocus();
            },
          ),
          const Divider(height: 1),
          NewNoteBodyField(
            noteId: noteId,
            focusNode: bodyFocusNode,
          ),
        ],
      ),
    );
  }
}
