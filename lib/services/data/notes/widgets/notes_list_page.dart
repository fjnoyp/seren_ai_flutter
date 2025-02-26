import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/cur_user_viewable_projects_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/widgets/project_notes_list.dart';

class NoteListPage extends HookConsumerWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curUser = ref.watch(curUserProvider).value;
    final curProjectId = useState<String?>(null);

    // Watch viewable projects to handle default project selection
    final viewableProjects = ref.watch(curUserViewableProjectsProvider);

    // Effect to handle default project selection
    useEffect(() {
      if (viewableProjects.hasValue) {
        final projects = viewableProjects.value!;
        final defaultProjectId = curUser?.defaultProjectId;

        // If default project exists and is in viewable projects, select it
        if (defaultProjectId != null &&
            projects.any((p) => p.id == defaultProjectId)) {
          curProjectId.value = defaultProjectId;
        } else {
          // Fallback to personal project (null) if default not found
          curProjectId.value = null;
        }
      }
      return null;
    }, [viewableProjects, curUser]);

    return Column(
      children: [
        _SelectProjectWidget(curProjectId),
        Expanded(child: ProjectNotesList(curProjectId.value)),
        CreateItemBottomButton(
          onPressed: () {
            ref
                .read(notesNavigationServiceProvider)
                .openNewNote(parentProjectId: curProjectId.value);
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
    return AsyncValueHandlerWidget(
      value: ref.watch(curUserViewableProjectsProvider),
      loading: () =>
          Center(child: Text(AppLocalizations.of(context)!.loadingProjects)),
      data: (projects) => (projects.isEmpty)
          ? Center(child: Text(AppLocalizations.of(context)!.noProjectsFound))
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
                  ...projects.map(
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
            ),
    );
  }
}
