import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/editablePageModeEnum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/notes_listener_fam_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/note_page.dart';
import 'package:seren_ai_flutter/services/data/projects/cur_user_viewable_projects_listener_provider.dart';

class NoteListPage extends HookConsumerWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUser = ref.read(curUserProvider).value;
    final curProjectId = useState<String?>(curUser?.defaultProjectId);

    return Column(
      children: [
        _SelectProjectWidget(curProjectId),
        Expanded(child: _NoteListByProjectId(curProjectId.value)),
        CreateItemBottomButton(
          onPressed: () {
            openNotePage(
              context,
              ref,
              mode: EditablePageMode.create,
              parentProjectId: curProjectId.value,
            );
          },
          buttonText: AppLocalizations.of(context)!.createNewNote,
        ),
      ],
    );
  }
}

class _SelectProjectWidget extends ConsumerWidget {
  const _SelectProjectWidget(this.curProjectId);

  final ValueNotifier<String?> curProjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(curUserViewableProjectsListenerProvider);

    return (projects?.isEmpty ?? true)
        ? Text(AppLocalizations.of(context)!.loadingProjects)
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: curProjectId.value == null,
                    onSelected: (value) => curProjectId.value = null,
                    label: Text(AppLocalizations.of(context)!.personal),
                    showCheckmark: false,
                  ),
                ),
                ...projects!.map(
                  (project) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: curProjectId.value == project.id,
                      onSelected: (value) => curProjectId.value = project.id,
                      label: Text(project.name),
                      showCheckmark: false,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class _NoteListByProjectId extends ConsumerWidget {
  const _NoteListByProjectId(this.projectId);

  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesListenerFamProvider(projectId));
    // TODO: use note list states instead to better handle errors
    return switch (notes) {
      null => const Center(child: CircularProgressIndicator()),
      [] => Center(
          child: Text(AppLocalizations.of(context)!.thisProjectHasNoNotes)),
      List() => ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteItem(notes[index]),
        ),
    };
  }
}

class _NoteItem extends ConsumerWidget {
  const _NoteItem(this.note);

  final NoteModel note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(note.name),
      subtitle: Text(
        note.description ?? '',
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        note.createdAt != null
            ? DateFormat.yMd(AppLocalizations.of(context)!.localeName)
                .add_jm()
                .format(note.date!.toLocal())
            : '',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        openNotePage(context, ref,
            mode: EditablePageMode.readOnly, noteId: note.id);
      },
    );
  }
}
