import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/common/generate_color_from_id.dart';
import 'package:seren_ai_flutter/services/data/common/status_enum.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/status_view.dart';
import 'package:seren_ai_flutter/services/data/projects/providers/project_by_id_stream_provider.dart';

class NoteListItemView extends ConsumerWidget {
  const NoteListItemView(
    this.note, {
    super.key,
    this.onTap,
    this.showStatus = false,
    this.showProject = false,
  });

  final NoteModel note;
  final void Function(String noteId)? onTap;
  final bool showStatus;
  final bool showProject;
  Widget _buildProjectIndicator(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        if (!showProject) return const SizedBox.shrink();

        final projectId = note.parentProjectId;
        if (projectId == null) {
          return Text(
            'Personal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 11,
                ),
          );
        }

        final noteProject = ref.watch(projectByIdStreamProvider(projectId));
        if (noteProject.valueOrNull == null) return const SizedBox.shrink();

        return Text(
          noteProject.valueOrNull!.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: generateColorFromId(projectId),
                fontSize: 11,
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: showStatus
          ? null // Use default padding when showing status
          : const EdgeInsets.only(
              right: 16), // Remove left padding when not showing status
      leading: showStatus
          ? Icon(
              getStatusIcon(note.status ?? StatusEnum.open),
              color: getStatusColor(note.status ?? StatusEnum.open),
              size: 24,
            )
          : null,
      title: Text(note.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectIndicator(context, ref),
          if (note.description?.isNotEmpty == true)
            Text(
              note.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (note.date != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd(AppLocalizations.of(context)!.localeName)
                      .add_jm()
                      .format(note.date!.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
      onTap: onTap != null
          ? () => onTap!(note.id)
          : () {
              ref
                  .read(notesNavigationServiceProvider)
                  .openNote(noteId: note.id);
            },
    );
  }
}
