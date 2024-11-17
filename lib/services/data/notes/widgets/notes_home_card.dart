import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/joined_note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class NotesCard extends ConsumerWidget {
  const NotesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUser = ref.read(curUserProvider).value;
    // TODO p3: maybe we should show personal notes here too

    return BaseHomeCard(
      title: AppLocalizations.of(context)!.notes,
      child: Center(
        child: AsyncValueHandlerWidget(
          value:
              ref.watch(curUserJoinedNotesProvider(curUser?.defaultProjectId)),
          data: (notes) => notes.isEmpty
              ? Text(AppLocalizations.of(context)!.noNotes)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...notes.take(2).map(
                          (note) => _NoteCardItem(note),
                        ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _NoteCardItem extends ConsumerWidget {
  final JoinedNoteModel joinedNote;

  const _NoteCardItem(this.joinedNote);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => openNotePage(context, ref,
          mode: EditablePageMode.readOnly, noteId: joinedNote.note.id),
      child: BaseHomeInnerCard.outlined(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Added inner padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                joinedNote.note.name,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                joinedNote.project?.name ??
                    AppLocalizations.of(context)!.personal,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
