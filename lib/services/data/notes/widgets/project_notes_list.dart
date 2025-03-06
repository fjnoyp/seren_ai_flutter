import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_by_project_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/async_value_handler_widget.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';

/// A notes list widget that groups notes by date ranges like Apple Notes
class ProjectNotesList extends ConsumerWidget {
  final String? projectId;
  final List<NoteModel>? providedNotes;
  final String? emptyMessage;

  /// Create a notes list for a specific project (or personal notes if projectId is null)
  const ProjectNotesList(
    this.projectId, {
    super.key,
    this.providedNotes,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If notes are provided directly, use them
    if (providedNotes != null) {
      return _NotesList(
          providedNotes!,
          emptyMessage ??
              AppLocalizations.of(context)!.thisProjectHasNoNotes);
    }

    // Otherwise, fetch notes from the provider
    return AsyncValueHandlerWidget(
      value: ref.watch(notesByProjectStreamProvider(projectId)),
      data: (notes) {
        return _NotesList(
            notes,
            emptyMessage ??
                AppLocalizations.of(context)!.thisProjectHasNoNotes);
      },
    );
  }
}

/// Common method to render a list of notes with Apple-style date grouping
class _NotesList extends ConsumerWidget {
  final List<NoteModel> notes;
  final String emptyMessage;

  const _NotesList(this.notes, this.emptyMessage);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) {
      return Center(child: Text(emptyMessage));
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
      sections.add(_Section(AppLocalizations.of(context)!.today, todayNotes));
    }

    if (yesterdayNotes.isNotEmpty) {
      sections.add(_Section("Yesterday", yesterdayNotes));
    }

    if (last7DaysNotes.isNotEmpty) {
      sections.add(_Section("Previous 7 Days", last7DaysNotes));
    }

    if (last30DaysNotes.isNotEmpty) {
      sections.add(_Section("Previous 30 Days", last30DaysNotes));
    }

    if (earlierNotes.isNotEmpty) {
      sections.add(_Section("Earlier", earlierNotes));
    }

    return ListView(
      children: sections,
    );
  }
}

class _Section extends ConsumerWidget {
  final String title;
  final List<NoteModel> notes;

  const _Section(this.title, this.notes);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ...notes.map((note) => _NoteCard(note)),
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
                    // Add the 3-dot menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      padding: EdgeInsets.zero,
                      position: PopupMenuPosition.under,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(context, ref, note);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.delete,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // Show a confirmation dialog before deleting the note
  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, NoteModel note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Delete the note
                ref.read(notesRepositoryProvider).deleteItem(note.id);
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
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
