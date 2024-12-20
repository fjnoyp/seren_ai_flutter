import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';

enum TaskSortOption {
  priority,
  dueDate,
  createdAt;

  String getDisplayName(BuildContext context) {
    switch (this) {
      case TaskSortOption.priority:
        return AppLocalizations.of(context)!.priority;
      case TaskSortOption.dueDate:
        return AppLocalizations.of(context)!.dueDate;
      case TaskSortOption.createdAt:
        return AppLocalizations.of(context)!.createdAt;
    }
  }

  Comparator<JoinedTaskModel> get comparator => switch (this) {
        TaskSortOption.priority => (a, b) =>
            (a.task.priority?.toInt() ?? double.maxFinite)
                .compareTo(b.task.priority?.toInt() ?? double.maxFinite),
        TaskSortOption.dueDate => (a, b) =>
            a.task.dueDate!.compareTo(b.task.dueDate!),
        TaskSortOption.createdAt => (a, b) =>
            a.task.createdAt!.compareTo(b.task.createdAt!),
      };
}
