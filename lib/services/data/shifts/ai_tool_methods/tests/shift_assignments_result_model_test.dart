import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seren_ai_flutter/services/data/shifts/ai_tool_methods/models/shift_assignments_result_model.dart';

void main() {
  group('ShiftAssignmentsResultModel', () {
    test('should correctly serialize and deserialize to/from JSON', () {
      // Create sample data
      final now =
          DateTime(2024, 3, 20); // Using fixed date for predictable testing
      final shiftAssignments = {
        now: [
          DateTimeRange(
            start: DateTime(2024, 3, 20, 9), // 9 AM
            end: DateTime(2024, 3, 20, 17), // 5 PM
          ),
          DateTimeRange(
            start: DateTime(2024, 3, 20, 18), // 6 PM
            end: DateTime(2024, 3, 20, 22), // 10 PM
          ),
        ],
      };

      final model = ShiftAssignmentsResultModel(
        shiftAssignments: shiftAssignments,
        totalShiftMinutes: 100,
        resultForAi: 'Sample result for AI',
      );

      // Convert to JSON
      final json = model.toJson();

      // Create new instance from JSON
      final deserializedModel = ShiftAssignmentsResultModel.fromJson(json);

      // Verify the data matches
      expect(deserializedModel.resultForAi, model.resultForAi);

      // Verify shift assignments
      expect(deserializedModel.shiftAssignments.length,
          model.shiftAssignments.length);

      final originalShifts = model.shiftAssignments[now]!;
      final deserializedShifts = deserializedModel.shiftAssignments[now]!;

      expect(deserializedShifts.length, originalShifts.length);
      expect(deserializedShifts[0].start, originalShifts[0].start);
      expect(deserializedShifts[0].end, originalShifts[0].end);
      expect(deserializedShifts[1].start, originalShifts[1].start);
      expect(deserializedShifts[1].end, originalShifts[1].end);
    });
  });
}
