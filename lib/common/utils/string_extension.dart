import 'dart:convert';

extension StringExtension on String {
  String getFilePathName() {
    return Uri.decodeFull(this).split('/').last;
  }

  String tryFormatAsJson() {
    try {
      return const JsonEncoder.withIndent('  ').convert(
        jsonDecode(this),
      );
    } catch (e) {
      return this; // Fallback to original content if not valid JSON
    }
  }
}
