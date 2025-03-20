import 'dart:math';

/// Temporary string similarity until we switch to using a db based FTS + semantic search
extension StringSimilarity on String {
  double similarity(String other) {
    String str1 = toLowerCase();
    String str2 = other.toLowerCase();

    if (str1 == str2) return 1.0;
    if (str1.isEmpty || str2.isEmpty) return 0.0;

    // Simple contains check first (for performance)
    if (str1.contains(str2) || str2.contains(str1)) return 0.8;

    // Levenshtein distance calculation
    var distance = _levenshteinDistance(str1, str2);
    var maxLength = max(str1.length, str2.length);

    return 1 - (distance / maxLength);
  }

  int _levenshteinDistance(String str1, String str2) {
    var m = str1.length;
    var n = str2.length;
    var matrix = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        var cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce(min);
      }
    }
    return matrix[m][n];
  }
}
