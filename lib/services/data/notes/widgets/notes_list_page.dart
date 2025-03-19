import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/create_item_bottom_button.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/select_project_widget.dart';
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
    // Add state to track if "All" is selected
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
        const SizedBox(height: 16),
        SelectProjectWidget(
          curProjectIdValueNotifier: curProjectId,
          showAllValueNotifier: showAllNotes,
          showPersonalOption: true,
        ),
        Expanded(
          // Choose which widget to show based on showAllNotes value
          child: showAllNotes.value
              ? const _AllNotesList() // Show all notes from recently updated provider
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
