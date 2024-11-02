// TODO p1: update logic to get multi day shift ranges based on timezone chosen 

abstract class ShiftQueries {
  /// Params:
  /// - day_start: DateTime
  /// - shift_id: String
  /// - day_of_week: int
  /// - user_id: String
  static const getActiveShiftRanges = '''
    WITH timeframe_ranges AS (
      SELECT 
        datetime(date(@day_start), substr(start_time, 1, 5)) as range_start,
        datetime(date(@day_start), time(substr(start_time, 1, 5), duration)) as range_end,
        0 as is_removal
      FROM shift_timeframes
      WHERE shift_id = @shift_id
        AND day_of_week = @day_of_week
    ),
    override_ranges AS (
      SELECT 
        start_datetime as range_start,
        end_datetime as range_end,
        is_removal
      FROM shift_overrides
      WHERE shift_id = @shift_id
        AND (user_id = @user_id OR user_id IS NULL)
        AND (date(start_datetime) = date(@day_start)
        OR date(end_datetime) = date(@day_start))
    )
    SELECT range_start, range_end
    FROM (
      SELECT range_start, range_end
      FROM timeframe_ranges t
      WHERE NOT EXISTS (
        SELECT 1 FROM override_ranges o
        WHERE o.is_removal = 1
          AND o.range_start < t.range_end 
          AND o.range_end > t.range_start
      )
      UNION ALL
      SELECT range_start, range_end
      FROM override_ranges
      WHERE is_removal = 0
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
  ''';

  /// Params:
  /// - shift_id: String
  /// - user_id: String
  /// - day_start: DateTime
  static const getUserShiftLogsForDay = '''
    SELECT * FROM shift_logs
    WHERE shift_id = @shift_id
      AND user_id = @user_id
      AND (DATE(clock_in_datetime) = DATE(@day_start)
      OR DATE(clock_out_datetime) = DATE(@day_start))
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
  static const getUserShifts = '''
  SELECT DISTINCT 
    s.id AS s_id,
    s.name AS s_name,
    s.author_user_id AS s_author_user_id,
    s.parent_project_id AS s_parent_project_id,
    s.created_at AS s_created_at,
    s.updated_at AS s_updated_at,
    p.id AS p_id,
    p.name AS p_name,
    p.description AS p_description,
    p.address AS p_address,
    p.parent_org_id AS p_parent_org_id,
    p.created_at AS p_created_at,
    p.updated_at AS p_updated_at
  FROM shifts s
  JOIN shift_user_assignments sua ON s.id = sua.shift_id
  JOIN projects p ON s.parent_project_id = p.id
  WHERE sua.user_id = @user_id
  ''';
}
