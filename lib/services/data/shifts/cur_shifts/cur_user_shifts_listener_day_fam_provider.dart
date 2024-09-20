/*
Initial attempt at determining data format and display logic for a user's shifts 
*/

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_user_provider.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/joined_shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_timeframe_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_log_model.dart';
import 'package:seren_ai_flutter/services/data/shifts/models/shift_override_model.dart';

class ShiftObject {
  final List<ShiftModel> shifts;
  final List<ShiftTimeframeModel> timeFrames;
  final List<ShiftLogModel> logs;
  final List<ShiftOverrideModel> overrides;

  ShiftObject({
    required this.shifts,
    required this.timeFrames,
    required this.logs,
    required this.overrides,
  });
}

// TODO p3: convert this to week provider so we can handle UTC -> local timezone issue conversions for specific days/shifts 
final curUserShiftsListenerDayFamProvider = AsyncNotifierProvider.family<
    CurUserShiftsListenerDayFamNotifier,
    List<JoinedShiftModel>,
    DateTime>(CurUserShiftsListenerDayFamNotifier.new);

class CurUserShiftsListenerDayFamNotifier
    extends FamilyAsyncNotifier<List<JoinedShiftModel>, DateTime> {
  @override
  Future<List<JoinedShiftModel>> build(DateTime day) async {
    final curUser = ref.read(curAuthUserProvider);
    final curUserId = curUser?.id;

    if (curUserId == null) {
      throw Exception('User not authenticated');
    }

    final db = ref.watch(dbProvider);

    // Calculate the day start and day end from the given DateTime
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(Duration(hours: 23, minutes: 59, seconds: 59));

    // 1. Get the list of shift ids assigned to the curUserId
    final shiftIdsQuery = '''
      SELECT DISTINCT s.id
      FROM shifts s
      JOIN shift_user_assignments sua ON s.id = sua.shift_id
      WHERE sua.user_id = '$curUserId'
    ''';
    final shiftIdsResult = await db.execute(shiftIdsQuery);
    final shiftIds = shiftIdsResult.map((row) => row['id'] as String).toList();

    final joinedShifts = <JoinedShiftModel>[];

    // 2. For each shift id in the list
    for (final shiftId in shiftIds) {
      // 3. Get all of its logs, timeframes, overrides for the current day
      final shiftQuery = '''
        SELECT * FROM shifts WHERE id = '$shiftId'
      ''';

      // TODO p3: missing exception case - we assume timeframe dayOfWeek always matches the actual day of week. However, if timeframe is specified at 12 am EST Monday, that would actually be 9 pm PST Sunday!
      final timeframesQuery = '''
        SELECT * FROM shift_timeframes 
        WHERE shift_id = '$shiftId' 
        AND day_of_week = ${day.weekday}
      ''';
      final logsQuery = '''
        SELECT * FROM shift_logs 
        WHERE shift_id = '$shiftId'
          AND user_id = '$curUserId'
          AND (DATE(clock_in_datetime) = DATE('${dayStart.toIso8601String()}')
          OR DATE(clock_out_datetime) = DATE('${dayStart.toIso8601String()}'))
      ''';
      final overridesQuery = '''
        SELECT * FROM shift_overrides 
        WHERE shift_id = '$shiftId'
          AND (user_id = '$curUserId' OR user_id IS NULL)
          AND DATE(start_datetime) = DATE('${dayStart.toIso8601String()}')
          OR DATE(end_datetime) = DATE('${dayStart.toIso8601String()}')
      ''';

      final shiftResult = await db.execute(shiftQuery);
      final timeframesResult = await db.execute(timeframesQuery);
      final logsResult = await db.execute(logsQuery);
      final overridesResult = await db.execute(overridesQuery);

      if (shiftResult.isNotEmpty) {
        final shift = ShiftModel.fromJson(shiftResult.first);
        final timeframes = timeframesResult
            .map((row) => ShiftTimeframeModel.fromJson(row))
            .toList();
        final logs =
            logsResult.map((row) => ShiftLogModel.fromJson(row)).toList();
        final overrides = overridesResult
            .map((row) => ShiftOverrideModel.fromJson(row))
            .toList();

        // 4. Use these to populate a list of JoinedShiftModel
        joinedShifts.add(JoinedShiftModel(
          shift: shift,
          timeFrames: timeframes,
          logs: logs,
          overrides: overrides,
        ));
      }
    }

    return joinedShifts;
  }
}
/*

THE PLAN FOR THIS CLASS: 

Our goal is to get a list of shifts for a user for a given day

1. First we need the shifts assigned for that user 
    - this is a list of shifts where the user is assigned to the shift 
    - use the curUserId as the user_id 

2. For each shift we need the shiftLogs, shiftTimeFrames, and shiftOverrides 
    - use the shift_id to get the shiftTimeFrames
    - using the provided DateTime arg, calculate the day start and end
    - use the start_datetime and end_datetime to get the shift_logs and shift_overrides that belong to that day and also to that user_id 

3. Put this all into an updated ShiftObject and return it 

*/

/*

ShiftTables SQL reference 

-- SHIFTS table
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    author_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    parent_project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE
);

-- SHIFT_USER_ASSIGNMENTS table
CREATE TABLE shift_user_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (shift_id, user_id)
);
CREATE INDEX idx_shift_user_assignments_user_id ON shift_user_assignments(user_id);

-- SHIFT_TIMEFRAMES table
CREATE TABLE shift_timeframes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    day INTEGER NOT NULL CHECK (day >= 0 AND day <= 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT check_end_time_after_start_time CHECK (end_time > start_time)
);
CREATE INDEX idx_shift_timeframes_shift_id ON shift_timeframes(shift_id);

-- SHIFT_LOGS table
CREATE TABLE shift_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    clock_in_datetime TIMESTAMPTZ NOT NULL,
    clock_out_datetime TIMESTAMPTZ,
    is_break BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT check_clock_out_after_clock_in CHECK (clock_out_datetime > clock_in_datetime)
);
CREATE INDEX idx_shift_logs_user_id ON shift_logs(user_id);
CREATE INDEX idx_shift_logs_shift_id ON shift_logs(shift_id);

-- SHIFT_OVERRIDES table
CREATE TABLE shift_overrides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- If null applies to all users in shift
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    start_datetime TIMESTAMPTZ NOT NULL, -- Week to apply override to
    day INTEGER CHECK (day >= 0 AND day <= 6),
    start_time TIME,
    end_time TIME,
    is_removal BOOLEAN NOT NULL DEFAULT FALSE, -- True if this override removes any overlapping shift_timeframes
    CONSTRAINT check_end_time_after_start_time CHECK (end_time > start_time)
);
CREATE INDEX idx_shift_overrides_user_id ON shift_overrides(user_id);
CREATE INDEX idx_shift_overrides_shift_id ON shift_overrides(shift_id);
CREATE INDEX idx_shift_overrides_start_datetime ON shift_overrides(start_datetime);

-- POWERSYNC publication 
DO $$
BEGIN
    BEGIN
        CREATE PUBLICATION powersync FOR TABLE public.shifts, public.shift_user_assignments, public.shift_timeframes, public.shift_logs, public.shift_overrides;
    EXCEPTION
        WHEN duplicate_object THEN
            ALTER PUBLICATION powersync ADD TABLE public.shifts, public.shift_user_assignments, public.shift_timeframes, public.shift_logs, public.shift_overrides;
    END;
END
$$;

*/
