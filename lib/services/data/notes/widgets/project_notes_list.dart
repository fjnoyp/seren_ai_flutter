import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';

/// A notes list widget that groups notes by date ranges like Apple Notes
class ProjectNotesList extends ConsumerWidget {
  final String? projectId;

  const ProjectNotesList(this.projectId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueHandlerWidget(
      value: ref.watch(notesByProjectStreamProvider(projectId)),
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
              child: Text(AppLocalizations.of(context)!.thisProjectHasNoNotes));
        }

        // Sort notes by updated_at timestamp (most recent first)
        final sortedNotes = [...notes];
        sortedNotes.sort((a, b) => (b.updatedAt ?? b.createdAt)!
            .compareTo(a.updatedAt ?? a.createdAt ?? DateTime(1970)));

        // Group notes by date ranges
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final last7Days = today.subtract(const Duration(days: 7));
        final last30Days = today.subtract(const Duration(days: 30));

        final todayNotes = <NoteModel>[];
        final yesterdayNotes = <NoteModel>[];
        final last7DaysNotes = <NoteModel>[];
        final last30DaysNotes = <NoteModel>[];
        final earlierNotes = <NoteModel>[];

        for (final note in sortedNotes) {
          final noteDate = note.updatedAt ?? note.createdAt;
          if (noteDate == null) {
            earlierNotes.add(note);
            continue;
          }

          final noteDay = DateTime(noteDate.year, noteDate.month, noteDate.day);

          if (noteDay.isAtSameMomentAs(today)) {
            todayNotes.add(note);
          } else if (noteDay.isAtSameMomentAs(yesterday)) {
            yesterdayNotes.add(note);
          } else if (noteDay.isAfter(last7Days)) {
            last7DaysNotes.add(note);
          } else if (noteDay.isAfter(last30Days)) {
            last30DaysNotes.add(note);
          } else {
            earlierNotes.add(note);
          }
        }

        // Build sections
        final sections = <Widget>[];

        if (todayNotes.isNotEmpty) {
          sections.add(_buildSection(
              context, ref, AppLocalizations.of(context)!.today, todayNotes));
        }

        if (yesterdayNotes.isNotEmpty) {
          sections
              .add(_buildSection(context, ref, "Yesterday", yesterdayNotes));
        }

        if (last7DaysNotes.isNotEmpty) {
          sections.add(
              _buildSection(context, ref, "Previous 7 Days", last7DaysNotes));
        }

        if (last30DaysNotes.isNotEmpty) {
          sections.add(
              _buildSection(context, ref, "Previous 30 Days", last30DaysNotes));
        }

        if (earlierNotes.isNotEmpty) {
          sections.add(_buildSection(context, ref, "Earlier", earlierNotes));
        }

        return ListView(
          children: sections,
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, WidgetRef ref, String title,
      List<NoteModel> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ),
        ...notes.map((note) => _NoteCard(note)).toList(),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// A card-style note item with bold title
class _NoteCard extends ConsumerWidget {
  final NoteModel note;

  const _NoteCard(this.note);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Format the time
    final timeString = _formatTime(context, note.updatedAt ?? note.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(notesNavigationServiceProvider).openNote(noteId: note.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                if (note.description != null &&
                    note.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // If it's today, just show the time
    if (noteDate.isAtSameMomentAs(today)) {
      return DateFormat.jm().format(dateTime.toLocal());
    }

    // Otherwise show the date
    return DateFormat.MMMd().format(dateTime.toLocal());
  }
}
