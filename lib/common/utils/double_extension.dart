extension DoubleExtension on double {
  String toStringAsPercentage() {
    return '${(this * 100).toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '')} %';
  }
}
