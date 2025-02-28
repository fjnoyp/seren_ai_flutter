import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for bottom app bars to ensure consistent styling and behavior
/// across different modes (quick actions, AI input, etc.)
class BottomAppBarBase extends ConsumerWidget {
  final Widget child;
  final Color? backgroundColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final Duration animationDuration;
  final bool elevated;
  final double? notchMargin;

  const BottomAppBarBase({
    super.key,
    required this.child,
    this.backgroundColor,
    this.height = 65.0,
    this.padding = EdgeInsets.zero,
    this.animationDuration = const Duration(milliseconds: 300),
    this.elevated = true,
    this.notchMargin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: animationDuration,
      decoration: BoxDecoration(
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, -2),
                  blurRadius: 4.0,
                ),
              ]
            : null,
      ),
      child: BottomAppBar(
        height: height,
        padding: padding,
        notchMargin: notchMargin ?? 0,
        color: backgroundColor ?? theme.bottomAppBarTheme.color,
        child: child,
      ),
    );
  }
}
