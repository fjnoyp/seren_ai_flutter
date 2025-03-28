import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

// TODO p5: use these enums in the repository updateTask methods instead
enum TaskFieldEnum {
  name,
  status,
  priority,
  dueDate,
  assignees,
  type,
  createdAt,
  updatedAt,
  author,
  project;

  String toHumanReadable(BuildContext context) => switch (this) {
        TaskFieldEnum.name => AppLocalizations.of(context)!.name,
        TaskFieldEnum.status => AppLocalizations.of(context)!.status,
        TaskFieldEnum.priority => AppLocalizations.of(context)!.priority,
        TaskFieldEnum.assignees => AppLocalizations.of(context)!.assignees,
        TaskFieldEnum.dueDate => AppLocalizations.of(context)!.dueDate,
        TaskFieldEnum.type => AppLocalizations.of(context)!.type,
        TaskFieldEnum.createdAt => AppLocalizations.of(context)!.creationDate,
        TaskFieldEnum.updatedAt => AppLocalizations.of(context)!.updatedAt,
        TaskFieldEnum.project => AppLocalizations.of(context)!.project,
        TaskFieldEnum.author => AppLocalizations.of(context)!.author,
      };
      
  Comparator<TaskModel>? get comparator => switch (this) {
        TaskFieldEnum.priority => (a, b) =>
            (a.priority?.toInt() ?? double.maxFinite)
                .compareTo(b.priority?.toInt() ?? double.maxFinite),
        TaskFieldEnum.dueDate => (a, b) =>
            (a.dueDate?.compareTo(b.dueDate ?? DateTime.now()) ?? 0),
        TaskFieldEnum.createdAt => (a, b) =>
            a.createdAt!.compareTo(b.createdAt!),
        TaskFieldEnum.updatedAt => (a, b) =>
            a.updatedAt!.compareTo(b.updatedAt!),
        TaskFieldEnum.name => null, // (a, b) => a.name.compareTo(b.name),
        // TODO p4: add comparator for status
        TaskFieldEnum.status => null,

        // the fields below are not sortable
        TaskFieldEnum.assignees => null,
        TaskFieldEnum.type => null,
        TaskFieldEnum.project => null,
        TaskFieldEnum.author => null,
      };
}
