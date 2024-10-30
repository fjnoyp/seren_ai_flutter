import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/auth_states.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';

class NotesCard extends ConsumerWidget {
  const NotesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUser = (ref.read(curAuthStateProvider) as LoggedInAuthState).user;
    // TODO: maybe we should show personal notes here too
    // TODO: sort list to pick the most recent ones
    final notes = ref.watch(notesListenerFamProvider(curUser.defaultProjectId));

    // TODO: refactor to use handable error state
    return BaseHomeCard(
      title: AppLocalizations.of(context)!.notes,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: switch (notes) {
          null => const CircularProgressIndicator(),
          [] => Text(AppLocalizations.of(context)!.noNotes),
          List() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...notes.take(2).map(
                      (note) => _NoteCardItem(note),
                    ),
              ],
            ),
        },
      ),
    );
  }
}

class _NoteCardItem extends ConsumerWidget {
  final NoteModel note;

  const _NoteCardItem(this.note);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => openNotePage(context, ref,
          mode: EditablePageMode.readOnly, noteId: note.id),
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Added inner padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                note.name,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                note.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
