import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

class TaskFilter {
  final TaskFieldEnum field;

  final bool Function(TaskModel) condition;
  //final bool Function(TaskModel, DateTimeRange)? dateRangeCondition;
  final String readableName;

  final bool? showDateRangePicker;

  TaskFilter({
    required this.field,
    required this.readableName,
    required this.condition,
    //this.dateRangeCondition,
    this.showDateRangePicker = false,
  });

  TaskFilter copyWith({
    bool Function(TaskModel)? condition,
    String? readableName,
  }) {
    return TaskFilter(
      field: field,
      readableName: readableName ?? this.readableName,
      condition: condition ?? this.condition,
      //dateRangeCondition: dateRangeCondition ?? this.dateRangeCondition,
    );
  }
}
