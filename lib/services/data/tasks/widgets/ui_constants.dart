
import 'package:flutter/material.dart';


bool _checkIsOverdue(DateTime? dueDate) => dueDate == null || DateTime.now().toUtc().isAfter(dueDate);

MaterialColor? getDueDateColor(DateTime? dueDate) => _checkIsOverdue(dueDate) ? Colors.red : null;


