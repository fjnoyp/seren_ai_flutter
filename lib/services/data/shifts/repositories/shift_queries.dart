// TODO p1: update logic to get multi day shift ranges based on timezone chosen

abstract class ShiftQueries {
  // TODO p1: does not support breaks
  /// Params:
  /// - day_start: DateTime
  /// - shift_id: String
  /// - day_of_week: int
  /// - user_id: String
  static const getActiveShiftRanges = '''
    SELECT *
    FROM (
      SELECT
        *,
        datetime(date(@day_start), substr(start_time, 1, 5)) as range_start,
        datetime(date(@day_start), time(substr(start_time, 1, 5), duration)) as range_end
      FROM shift_timeframes t
      WHERE NOT EXISTS (
        SELECT 1 FROM shift_overrides o
        WHERE o.is_removal = 1
          AND o.start_datetime < range_end 
          AND o.end_datetime > range_start
      )
        AND shift_id = @shift_id
        AND day_of_week = @day_of_week
      UNION ALL
      SELECT
        o.id,
        o.shift_id,
        @day_of_week as day_of_week,
        time(o.start_datetime) as start_time,
        datetime(date(@day_start), time(o.end_datetime)) - datetime(date(@day_start), time(o.start_datetime)) as duration,
        o.created_at,
        o.updated_at,
        o.start_datetime as range_start,
        o.end_datetime as range_end
      FROM shift_overrides o
      WHERE o.shift_id = @shift_id
        AND is_removal = 0
        AND (user_id = @user_id OR user_id IS NULL)
        AND (date(start_datetime) = date(@day_start)
        OR date(end_datetime) = date(@day_start))
    )
    ORDER BY range_start;
  ''';

  /// Params:
  /// - shift_id: String
  /// - user_id: String
  static const getCurrentShiftLogs = '''
    SELECT * FROM shift_logs
    WHERE shift_id = @shift_id
      AND user_id = @user_id
      AND clock_out_datetime IS NULL
      AND is_deleted = false
  ''';

  /// Params:
  /// - shift_id: String
  /// - user_id: String
  /// - day_start: DateTime
  static const getUserShiftLogsForDay = '''
    SELECT * FROM shift_logs
    WHERE shift_id = @shift_id
      AND user_id = @user_id
      AND is_deleted = false
      AND (DATE(clock_in_datetime) = DATE(@day_start))
  ''';

  /// Params:
  /// - shift_id: String
  /// - user_id: String
  /// - day_start: DateTime
  static const getUserShiftOverridesForDay = '''
    SELECT * FROM shift_overrides
    WHERE shift_id = @shift_id
      AND (user_id = @user_id OR user_id IS NULL)
      AND DATE(start_datetime) = DATE(@day_start)
      OR DATE(end_datetime) = DATE(@day_start)
  ''';

  /// Params:
  /// - shift_id: String
  static const getShiftTimeframes = '''
    SELECT * FROM shift_timeframes
    WHERE shift_id = @shift_id
  ''';

  /// Params:
  /// - user_id: String
  /// - org_id: String
  static const getUserShifts = '''
  SELECT DISTINCT s.*
  FROM shifts s
  JOIN shift_user_assignments sua ON s.id = sua.shift_id
  JOIN projects p ON s.parent_project_id = p.id
  WHERE sua.user_id = @user_id
  AND p.parent_org_id = @org_id
  ''';
}
