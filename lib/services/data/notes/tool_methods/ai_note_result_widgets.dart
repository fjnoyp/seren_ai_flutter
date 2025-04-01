import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/create_note_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/update_note_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/note_edit_operation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateNoteResultWidget extends ConsumerWidget {
  final CreateNoteResultModel result;
  const CreateNoteResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return !ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Text(AppLocalizations.of(context)!
            .createdNewTaskAndOpenedTaskPage(result.note.name)
            .replaceAll('task', 'note'))
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!
                  .createdNewTask(result.note.name)
                  .replaceAll('task', 'note')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.note.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (result.note.description != null &&
                            result.note.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            result.note.description!,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (result.note.date != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${result.note.date!.day}/${result.note.date!.month}/${result.note.date!.year}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                        if (result.note.address != null &&
                            result.note.address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  result.note.address!,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (result.note.actionRequired != null &&
                            result.note.actionRequired!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.assignment,
                                  size: 16, color: theme.colorScheme.error),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Action required: ${result.note.actionRequired!}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}

/// Widget to display the results of an UpdateNoteRequestModel
class UpdateNoteResultWidget extends ConsumerWidget {
  final UpdateNoteResultModel result;
  const UpdateNoteResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // If we're not in the AI chats route, just show a simple text
    if (!ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)) {
      return Text(
        "Updated note \"${result.note.name}\" with new content",
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Updated note \"${result.note.name}\""),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.note.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show the diff view only if we have multiple operations
                  if (result.editOperations.length > 1) ...[
                    _buildEditDiffView(context, result.editOperations),
                  ]
                  // Otherwise show the plain updated text
                  else if (result.note.description != null &&
                      result.note.description!.isNotEmpty) ...[
                    Text(
                      result.note.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a visual representation of the edit operations
  Widget _buildEditDiffView(
      BuildContext context, List<NoteEditOperation> operations) {
    final theme = Theme.of(context);

    // Create rich text spans for each operation
    final List<InlineSpan> spans = [];

    for (final op in operations) {
      switch (op.type) {
        case 'keep':
          spans.add(TextSpan(
            text: op.text,
            style: theme.textTheme.bodyMedium,
          ));
          break;
        case 'add':
          spans.add(TextSpan(
            text: op.text,
            style: TextStyle(
              color: Colors.green.shade700,
              backgroundColor: Colors.green.shade50,
              fontWeight: FontWeight.bold,
            ),
          ));
          break;
        case 'remove':
          spans.add(TextSpan(
            text: op.text,
            style: TextStyle(
              color: Colors.red.shade700,
              backgroundColor: Colors.red.shade50,
              decoration: TextDecoration.lineThrough,
            ),
          ));
          break;
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
