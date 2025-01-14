import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';

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

  Comparator<TaskModel> get comparator => switch (this) {
        TaskSortOption.priority => (a, b) =>
            (a.priority?.toInt() ?? double.maxFinite)
                .compareTo(b.priority?.toInt() ?? double.maxFinite),
        TaskSortOption.dueDate => (a, b) =>
            a.dueDate!.compareTo(b.dueDate!),
        TaskSortOption.createdAt => (a, b) =>
            a.createdAt!.compareTo(b.createdAt!),
      };
}
