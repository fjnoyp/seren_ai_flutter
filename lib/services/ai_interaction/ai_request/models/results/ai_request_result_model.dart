import 'package:seren_ai_flutter/services/ai_interaction/ai_request/models/results/error_request_result_model.dart';
import 'package:seren_ai_flutter/services/ai_interaction/last_ai_message_listener_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_assignments_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_clock_in_out_result_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/tool_methods/models/shift_log_results_model.dart';

enum AiRequestResultType {
  shiftAssignments('shift_assignments'),
  shiftLogs('shift_logs'), 
  shiftClockInOut('shift_clock_in_out'),
  findTasks('find_tasks'),
  createTask('create_task'),
  error('error');  
  //unknown('unknown');

  final String value;
  const AiRequestResultType(this.value);

  static AiRequestResultType fromString(String value) {
    return AiRequestResultType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid AiRequestResultType: $value'),
    );
  }
}


/// Result of an AI Request execution. 
/// 
/// Only the message field is sent to ai, all other fields are for display purposes. 
abstract class AiRequestResultModel extends AiResult {

  /// Result of the AI Request to be displayed to the user 
  final String resultForAi;

  final bool showOnly;

  final AiRequestResultType resultType; 

  AiRequestResultModel({required this.resultForAi, required this.showOnly, required this.resultType});

Map<String, dynamic> toJson() {
    return {
      'result_type': resultType.value,
      'result_for_ai': resultForAi,
      'show_only': showOnly,
    };
  }

  // Static factory method for deserialization
  factory AiRequestResultModel.fromJson(Map<String, dynamic> json) {
    final resultType = AiRequestResultType.fromString(json['result_type']);
    
    switch (resultType) {
      case AiRequestResultType.shiftAssignments:
        return ShiftAssignmentsResultModel.fromJson(json);
      case AiRequestResultType.shiftLogs:
        return ShiftLogsResultModel.fromJson(json);
      case AiRequestResultType.shiftClockInOut:
        return ShiftClockInOutResultModel.fromJson(json);
      default:
        return ErrorRequestResultModel.fromJson(json);
        //throw Exception('Unknown type for AiRequestResultModel: $resultType');
    }
  }
}

