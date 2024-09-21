   Duration parseDuration(String interval) {
    final parts = interval.split(':');
    if (parts.length == 3) {
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
    } else {
      // Handle more complex interval formats if needed
      // For simplicity, this example assumes "HH:MM:SS" format
      return Duration.zero;
    }
  }

   String durationToString(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }



  bool boolFromInt(int value) => value == 1;
  int boolToInt(bool value) => value ? 1 : 0;