extension StringExtension on String {
  String get enumToHumanReadable {
    //
    final enumValue = split('.').last;

    // Split the string at each uppercase letter
    final words = enumValue.split(RegExp(r'(?=[A-Z])'));

    // Capitalize the first letter of each word and join them
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String getFilePathName() {
    return Uri.decodeFull(this).split('/').last;
  }
}
