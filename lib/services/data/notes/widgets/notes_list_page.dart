import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
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
    // Add state to track if "All Notes" is selected
    final showAllNotes = useState<bool>(false);

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
          showAllNotes.value = false;
        } else {
          // Fallback to personal project (null) if default not found
          curProjectId.value = null;
          showAllNotes.value = false;
        }
      }
      return null;
    }, [viewableProjects, curUser]);

    return Column(
      children: [
        _SelectProjectWidget(curProjectId, showAllNotes),
        Expanded(
          // Choose which widget to show based on showAllNotes value
          child: showAllNotes.value
              ? _AllNotesList() // Show all notes from recently updated provider
              : ProjectNotesList(
                  curProjectId.value), // Show project-specific notes
        ),
        if (kIsWeb)
          CreateItemBottomButton(
            onPressed: () {
              // When "All" is selected, create a personal note
              final projectIdForNewNote = showAllNotes.value
                  ? null // Create a personal note when "All" is selected
                  : curProjectId.value; // Otherwise use the selected project

              ref.read(notesNavigationServiceProvider).openNewNote(
                    parentProjectId: projectIdForNewNote,
                  );
            },
            buttonText: AppLocalizations.of(context)!.createNewNote,
          ),
      ],
    );
  }
}

/// Widget to display all notes across projects using recentUpdatedNotesStreamProvider
class _AllNotesList extends ConsumerWidget {
  const _AllNotesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(recentUpdatedNotesStreamProvider),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (notes) {
        // Use the enhanced ProjectNotesList to render the notes
        // Pass null for projectId since this is showing "All Notes"
        return ProjectNotesList(
          null,
          providedNotes: notes,
          emptyMessage: AppLocalizations.of(context)!.noNotes,
        );
      },
    );
  }
}

class _SelectProjectWidget extends ConsumerWidget {
  const _SelectProjectWidget(this.curProjectId, this.showAllNotes);

  final ValueNotifier<String?> curProjectId;
  final ValueNotifier<bool> showAllNotes;

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
                  // "All" filter chip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: showAllNotes.value,
                      onSelected: (value) {
                        showAllNotes.value = value;
                        if (value) {
                          // When selecting "All", don't change the current project ID
                          // Just remember it for when they switch back
                        } else if (curProjectId.value == null) {
                          // Make sure we're showing something when unselecting
                          showAllNotes.value = false;
                        }
                      },
                      label: Text("All Notes"),
                      showCheckmark: false,
                      avatar: const Icon(Icons.notes, size: 16),
                    ),
                  ),
                  // Personal filter chip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected:
                          !showAllNotes.value && curProjectId.value == null,
                      onSelected: (value) {
                        if (value) {
                          curProjectId.value = null;
                          showAllNotes.value = false;
                        }
                      },
                      label: Text(AppLocalizations.of(context)!.personal),
                      showCheckmark: false,
                    ),
                  ),
                  // Project filter chips
                  ...projects.map(
                    (project) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: !showAllNotes.value &&
                            curProjectId.value == project.id,
                        onSelected: (value) {
                          if (value) {
                            curProjectId.value = project.id;
                            showAllNotes.value = false;
                          }
                        },
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
