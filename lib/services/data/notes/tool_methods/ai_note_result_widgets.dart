import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/common/universal_platform/universal_platform.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/notes_navigation_service.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/create_note_result_model.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/update_note_result_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateNoteResultWidget extends ConsumerWidget {
  final CreateNoteResultModel result;
  const CreateNoteResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Widget? fieldsWidget;
    if (result.createdFields.isNotEmpty) {
      fieldsWidget = Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note created with:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            ...result.createdFields.entries.map((entry) {
              if (entry.value is List) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '• ${entry.key}: ${(entry.value as List).join(', ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
            }),
          ],
        ),
      );
    }

    return isWebVersion ||
            ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!
                  .createdNewTask(result.note.name)
                  .replaceAll('task', 'note')),
              if (fieldsWidget != null) fieldsWidget,
              InkWell(
                onTap: () {
                  ref
                      .read(notesNavigationServiceProvider)
                      .openNote(noteId: result.note.id);
                },
                child: Padding(
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
              ),
            ],
          )
        : Text(AppLocalizations.of(context)!
            .createdNewTaskAndOpenedTaskPage(result.note.name)
            .replaceAll('task', 'note'));
  }
}

/// Widget to display the results of an UpdateNoteRequestModel
class UpdateNoteResultWidget extends ConsumerWidget {
  final UpdateNoteResultModel result;
  const UpdateNoteResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Only show edit operations details for English language
    Widget? editOperationsWidget;
    if (result.editOperations.isNotEmpty) {
      editOperationsWidget = Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit operations:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            ...result.editOperations.map((operation) {
              IconData icon = Icons.edit; // Default icon
              Color color = Colors.blue; // Default color

              if (operation.type == 'add') {
                icon = Icons.add;
                color = Colors.green;
              } else if (operation.type == 'remove') {
                icon = Icons.remove;
                color = Colors.red;
              } else if (operation.type == 'keep') {
                icon = Icons.check;
                color = Colors.grey;
              }

              return Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        operation.text,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    return isWebVersion ||
            ref.read(currentRouteProvider).contains(AppRoutes.aiChats.name)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .updatedTask(result.note.name)
                    .replaceAll('task', 'note'),
              ),
              if (editOperationsWidget != null) editOperationsWidget,
              InkWell(
                onTap: () {
                  ref
                      .read(notesNavigationServiceProvider)
                      .openNote(noteId: result.note.id);
                },
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : Text(
            AppLocalizations.of(context)!
                .updatedTaskAndShowedResultInUI(result.note.name)
                .replaceAll('task', 'note'),
          );
  }
}
