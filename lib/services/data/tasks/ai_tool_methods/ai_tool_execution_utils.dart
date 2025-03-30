/// Utility class for handling special user keywords like "MYSELF"
class AiToolExecutionUtils {
  /// The keyword to identify the current user
  static const String myselfKeyword = "MYSELF";

  /// Checks if a string is the MYSELF keyword (case-insensitive)
  static bool isMyselfKeyword(String? text) {
    return text != null && text.toUpperCase() == myselfKeyword;
  }

  /// Checks if a list of strings contains the MYSELF keyword
  static bool containsMyselfKeyword(List<String>? texts) {
    return texts != null && texts.any((text) => isMyselfKeyword(text));
  }
}
