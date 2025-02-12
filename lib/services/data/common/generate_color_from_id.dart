import 'package:flutter/rendering.dart';

/// Helper function moved from color provider
Color generateColorFromId(String id) {
  final hash = id.hashCode;
  final hue = (hash % 360).abs().toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.6, 0.6).toColor();
}
