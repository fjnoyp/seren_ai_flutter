import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/common/widgets/form/color_animation.dart';
import 'package:seren_ai_flutter/services/data/notes/providers/note_by_id_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Custom hook to handle field state management and sync logic
class FieldState {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEditing;
  final String currentValue;
  final String lastSyncedValue;
  final Animation<Color?> colorAnimation;
  final Function(String) updateValue;
  final Function() handleSubmit;

  FieldState({
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.currentValue,
    required this.lastSyncedValue,
    required this.colorAnimation,
    required this.updateValue,
    required this.handleSubmit,
  });
}

FieldState useNoteField({
  required WidgetRef ref,
  required BuildContext context,
  required String noteId,
  required String provider,
  required FocusNode? externalFocusNode,
  required Function(WidgetRef, String, String) updateRepositoryFunction,
  required Function? onSubmitted,
}) {
  // Determine which provider to watch based on the type
  final currentValue = ref.watch(provider == 'name'
      ? noteByIdStreamProvider(noteId).select((note) => note.value?.name ?? '')
      : noteByIdStreamProvider(noteId)
          .select((note) => note.value?.description ?? ''));

  final controller = useTextEditingController(text: currentValue);
  final internalFocusNode = externalFocusNode ?? useFocusNode();

  // Track the last synced value to prevent unexpected resets
  final lastSyncedValue = useState(currentValue);

  // Track if user is currently editing
  final isEditing = useState(false);

  final colorAnimation = useAiActionColorAnimation(
    context,
    ref,
    triggerValue: currentValue,
  );

  // Update the value function
  void updateValue(String newValue) {
    if (newValue != currentValue) {
      updateRepositoryFunction(ref, noteId, newValue);
      lastSyncedValue.value = newValue;
    }
  }

  // Listen for focus changes
  useEffect(() {
    void onFocusChange() {
      isEditing.value = internalFocusNode.hasFocus;

      // When focus is gained, sync with provider if needed
      if (internalFocusNode.hasFocus) {
        // Only sync if controller doesn't have user changes
        if (controller.text == lastSyncedValue.value &&
            controller.text != currentValue) {
          controller.text = currentValue;
          lastSyncedValue.value = currentValue;
        }
      } else {
        // When focus is lost, save changes
        updateValue(controller.text);
      }
    }

    internalFocusNode.addListener(onFocusChange);
    return () => internalFocusNode.removeListener(onFocusChange);
  }, [internalFocusNode, currentValue]);

  // Only sync from provider if:
  // 1. We're not actively editing
  // 2. The provider value has changed from what we last synced (external change)
  // 3. The user hasn't made changes to the controller since last sync
  useEffect(() {
    if (!isEditing.value &&
        currentValue != lastSyncedValue.value &&
        controller.text == lastSyncedValue.value) {
      controller.text = currentValue;
      lastSyncedValue.value = currentValue;
    }
    return null;
  }, [currentValue]);

  // Handle submit function
  void handleSubmit() {
    updateValue(controller.text);
    if (onSubmitted != null) {
      onSubmitted();
    }
  }

  return FieldState(
    controller: controller,
    focusNode: internalFocusNode,
    isEditing: isEditing.value,
    currentValue: currentValue,
    lastSyncedValue: lastSyncedValue.value,
    colorAnimation: colorAnimation.colorTween,
    updateValue: updateValue,
    handleSubmit: handleSubmit,
  );
}

/// A new title field for notes that mimics the iPhone Notes app experience
class NewNoteTitleField extends HookConsumerWidget {
  final String noteId;
  final FocusNode? focusNode;
  final Function? onSubmitted;

  const NewNoteTitleField({
    super.key,
    required this.noteId,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldState = useNoteField(
      ref: ref,
      context: context,
      noteId: noteId,
      provider: 'name',
      externalFocusNode: focusNode,
      updateRepositoryFunction: (ref, noteId, value) =>
          ref.read(notesRepositoryProvider).updateNoteName(noteId, value),
      onSubmitted: onSubmitted,
    );

    return AnimatedBuilder(
      animation: fieldState.colorAnimation,
      builder: (context, child) {
        return TextField(
          controller: fieldState.controller,
          focusNode: fieldState.focusNode,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: fieldState.colorAnimation.value,
                fontWeight: FontWeight.w500,
              ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            hintText: 'Title',
            // Remove all borders and background
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onSubmitted: (_) => fieldState.handleSubmit(),
          onEditingComplete: () =>
              fieldState.updateValue(fieldState.controller.text),
          onTapOutside: (_) =>
              fieldState.updateValue(fieldState.controller.text),
        );
      },
    );
  }
}

/// A new body field for notes that mimics the iPhone Notes app experience
class NewNoteBodyField extends HookConsumerWidget {
  final String noteId;
  final FocusNode? focusNode;

  const NewNoteBodyField({
    super.key,
    required this.noteId,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldState = useNoteField(
      ref: ref,
      context: context,
      noteId: noteId,
      provider: 'description',
      externalFocusNode: focusNode,
      updateRepositoryFunction: (ref, noteId, value) => ref
          .read(notesRepositoryProvider)
          .updateNoteDescription(noteId, value),
      onSubmitted: null,
    );

    // For multiline fields, implement auto-save with debouncing
    final debounceTimer = useState<Future<void>?>(null);

    useEffect(() {
      void onChange() {
        if (fieldState.controller.text != fieldState.lastSyncedValue) {
          if (debounceTimer.value != null) {
            // Cancel previous timer
            debounceTimer.value = null;
          }

          // Create a new timer
          debounceTimer.value =
              Future.delayed(const Duration(milliseconds: 500), () {
            if (fieldState.controller.text != fieldState.currentValue) {
              fieldState.updateValue(fieldState.controller.text);
            }
          });
        }
      }

      fieldState.controller.addListener(onChange);
      return () => fieldState.controller.removeListener(onChange);
    }, [fieldState.controller]);

    return AnimatedBuilder(
      animation: fieldState.colorAnimation,
      builder: (context, child) {
        return TextField(
          controller: fieldState.controller,
          focusNode: fieldState.focusNode,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: fieldState.colorAnimation.value,
              ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
            hintText: 'Note',
            // Remove all borders and background
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onTapOutside: (_) =>
              fieldState.updateValue(fieldState.controller.text),
          onEditingComplete: () =>
              fieldState.updateValue(fieldState.controller.text),
        );
      },
    );
  }
}
