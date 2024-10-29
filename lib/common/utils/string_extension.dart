extension StringExtension on String {
  String filePathToName() {
    return Uri.decodeFull(this).split('/').last;
  }
}
