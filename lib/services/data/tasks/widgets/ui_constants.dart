
import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';


bool _checkIsOverdue(DateTime? dueDate) => dueDate == null || DateTime.now().toUtc().isAfter(dueDate);

MaterialColor? getDueDateColor(DateTime? dueDate) => _checkIsOverdue(dueDate) ? Colors.red : null;


