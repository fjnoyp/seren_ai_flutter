import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

class TaskFilter {
  final TaskFieldEnum field;
  final String value;
  final bool Function(TaskModel)? condition;
  final bool Function(TaskModel, DateTimeRange)? dateRangeCondition;
  final String readableName;

  TaskFilter({
    required this.field,
    required this.value,
    required this.readableName,
    this.condition,
    this.dateRangeCondition,
  }) : assert(condition != null || dateRangeCondition != null,
            'Either condition or dateRangeCondition must be provided');

  TaskFilter copyWith({String? readableName}) {
    return TaskFilter(
      field: field,
      value: value,
      readableName: readableName ?? this.readableName,
      condition: condition,
      dateRangeCondition: dateRangeCondition,
    );
  }
}
