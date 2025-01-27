import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/navigation_service_provider.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/widgets/home/base_home_card.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';

class NoteHomeCard extends ConsumerWidget {
  const NoteHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUser = ref.read(curUserProvider).value;
    // TODO p3: maybe we should show personal notes here too

    return BaseHomeCard(
      title: AppLocalizations.of(context)!.notes,
      child: Center(
        child: AsyncValueHandlerWidget(
          value: ref
              .watch(notesByProjectStreamProvider(curUser?.defaultProjectId)),
          data: (notes) => notes.isEmpty
              ? Text(AppLocalizations.of(context)!.noNotes)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...notes.take(2).map(
                          (note) => _NoteCardItem(note: note),
                        ),
                    BaseHomeInnerCard.filled(
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(navigationServiceProvider)
                              .navigateTo(AppRoutes.noteList.name);
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              AppLocalizations.of(context)!.seeAll,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _NoteCardItem extends ConsumerWidget {
  final NoteModel note;

  const _NoteCardItem({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref
          .read(notesNavigationServiceProvider)
          .openNote(noteId: note.id),
      child: BaseHomeInnerCard.outlined(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              note.name,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
