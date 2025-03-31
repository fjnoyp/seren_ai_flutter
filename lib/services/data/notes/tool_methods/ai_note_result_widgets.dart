import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/common/current_route_provider.dart';
import 'package:seren_ai_flutter/common/routes/app_routes.dart';
import 'package:seren_ai_flutter/services/data/notes/tool_methods/models/create_note_result_model.dart';
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
