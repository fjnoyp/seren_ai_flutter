import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_field_enum.dart';

class TaskFilter {
  final TaskFieldEnum field;

  /// This filters the tasks synchronously.
  ///
  /// For filters that use async conditions,
  /// this will be used for the initial filtering.
  final bool Function(TaskModel) condition;

  /// This filters the tasks asynchronously.
  final Future<bool> Function(TaskModel)? asyncCondition;

  final String readableName;

  final bool? showDateRangePicker;

  TaskFilter({
    required this.field,
    required this.readableName,
    required this.condition,
    this.asyncCondition,
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
      asyncCondition: asyncCondition,
    );
  }
}
