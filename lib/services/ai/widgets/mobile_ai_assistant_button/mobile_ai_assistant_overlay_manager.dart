import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AiAssistantOverlayType {
  results,
  textInput,
  transcription,
}

class MobileAiAssistantOverlayManager {
  static final Map<AiAssistantOverlayType, OverlayEntry?> _entries = {};

  // Track if we're in the process of showing/hiding to prevent race conditions
  static final Map<AiAssistantOverlayType, bool> _processingOperation = {};

  // Default position from bottom of screen
  static const double defaultBottomPosition = 100.0;

  static void show({
    required BuildContext context,
    required AiAssistantOverlayType type,
    required GlobalKey anchorKey,
    required Widget Function(BuildContext) builder,
  }) {
    // Don't show if already showing (prevents re-entry)
    if (isShowing(type) || _processingOperation[type] == true) {
      return;
    }

    // Mark as processing to prevent race conditions
    _processingOperation[type] = true;

    // Close any existing overlay of this type
    hide(type);

    // Use a post-frame callback to avoid build-phase errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Double-check we still want to show this overlay
      if (_processingOperation[type] != true || !context.mounted) {
        _processingOperation[type] = false;
        return;
      }

      final overlayEntry = OverlayEntry(
        builder: (overlayContext) {
          // Get keyboard height to adjust position
          final keyboardHeight =
              MediaQuery.of(overlayContext).viewInsets.bottom;
          final bottomPosition = keyboardHeight > 0
              ? keyboardHeight + 8.0 // Add a small gap above keyboard
              : defaultBottomPosition;

          // Overlays are added to the widget tree at a different level
          // than your main application widgets, which can cause issues
          // with provider inheritance and rebuilding.
          // This is a known issue with Flutter overlays
          // and state management systems like Riverpod.
          // To fix this, we can use an UncontrolledProviderScope
          // to create a new provider scope for the overlay.
          return UncontrolledProviderScope(
            container: ProviderScope.containerOf(context),
            child: Positioned(
              bottom: bottomPosition,
              left: 0,
              right: 0,
              child: Center(
                child: builder(overlayContext),
              ),
            ),
          );
        },
      );

      _entries[type] = overlayEntry;

      try {
        Overlay.of(context).insert(overlayEntry);
      } catch (e) {
        debugPrint('Failed to insert overlay: $e');
        _entries[type] = null;
      }

      _processingOperation[type] = false;
    });
  }

  static void hide(AiAssistantOverlayType type) {
    final entry = _entries[type];

    if (entry != null) {
      // Mark as processing
      _processingOperation[type] = true;

      // Mark this entry as being removed by setting it to null first
      // This prevents multiple remove attempts on the same entry
      final localEntry = entry;
      _entries[type] = null;

      // Use try-catch to safely handle overlay removal
      try {
        // Use post-frame callback for hiding too
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            localEntry.remove();
          } catch (e) {
            // Ignore errors from removing already-removed entries
            debugPrint('Ignored error removing overlay: $e');
          }
          _processingOperation[type] = false;
        });
      } catch (e) {
        debugPrint('Failed to schedule overlay removal: $e');
        _processingOperation[type] = false;
      }
    }
  }

  static void hideAll() {
    for (final type in AiAssistantOverlayType.values) {
      hide(type);
    }
  }

  static bool isShowing(AiAssistantOverlayType type) {
    return _entries[type] != null;
  }
}
