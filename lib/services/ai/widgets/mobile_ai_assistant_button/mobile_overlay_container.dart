import 'package:flutter/material.dart';

/// A container with standard styling for floating UI elements
class MobileOverlayContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool needsMaterial;
  final BoxConstraints? constraints;

  /// Standard constraints for overlay widgets
  static const BoxConstraints standardOverlayConstraints = BoxConstraints(
    minWidth: 280,
    maxWidth: 320, // Fixed maximum width to ensure space on sides
    maxHeight: 300,
  );

  const MobileOverlayContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
    this.needsMaterial = false,
    this.constraints = standardOverlayConstraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final container = Container(
      width: 320, // Fixed width to ensure it doesn't expand to full screen
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!needsMaterial)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );

    return container;
  }
}
