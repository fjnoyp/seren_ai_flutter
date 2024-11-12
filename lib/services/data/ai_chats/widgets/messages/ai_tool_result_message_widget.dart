import 'package:flutter/material.dart';
import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/ai_request_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/shift_result_widgets.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/create_task_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/models/find_tasks_result_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/tool_result_widgets.dart';

class AiToolResultMessageWidget extends StatelessWidget {
  final AiRequestResultModel result;

  const AiToolResultMessageWidget(this.result, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: switch (result.resultType) {
        AiRequestResultType.shiftAssignments => ShiftAssignmentsResultWidget(
            result: result as ShiftAssignmentsResultModel),
        AiRequestResultType.shiftLogs =>
          ShiftLogsResultWidget(result: result as ShiftLogsResultModel),
        AiRequestResultType.shiftClockInOut => ShiftClockInOutResultWidget(
            result: result as ShiftClockInOutResultModel),
        AiRequestResultType.findTasks =>
          FindTasksResultWidget(result: result as FindTasksResultModel),
        AiRequestResultType.createTask =>
          CreateTaskResultWidget(result: result as CreateTaskResultModel),
        AiRequestResultType.error => Text(result.resultForAi)
      },
    );
  }
}
