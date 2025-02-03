import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskBudgetSection extends ConsumerWidget {
  const TaskBudgetSection(this.taskId, {super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Task budgets are not implemented yet'));
  }
}
