
import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';


bool _checkIsOverdue(DateTime? dueDate) => dueDate == null || DateTime.now().toUtc().isAfter(dueDate);

MaterialColor? getDueDateColor(DateTime? dueDate) => _checkIsOverdue(dueDate) ? Colors.red : null;


MaterialColor? getTaskPriorityColor(PriorityEnum priority) {
  switch (priority) {
    case PriorityEnum.veryHigh:
      return Colors.red;
    case PriorityEnum.high:
      return Colors.orange;
    case PriorityEnum.normal:
      return Colors.blue;
    case PriorityEnum.low:
      return Colors.grey;
    case PriorityEnum.veryLow:
      return Colors.lightBlue;
    default:
      return null;
  }
}