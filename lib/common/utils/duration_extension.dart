
extension DurationFormatting on Duration {
  String formatDuration() {
    String twoDigits(int n) => n.toString();
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));
    return hours == "0" && minutes == "0" ? "0 hours" : minutes == "0" ? "$hours hours" : "$hours:$minutes hours";
  }
}
