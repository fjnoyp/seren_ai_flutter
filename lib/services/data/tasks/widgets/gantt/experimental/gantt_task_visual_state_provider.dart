import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/widgets/gantt/experimental/viewable_tasks_hierarchy_provider.dart';

class GanttTaskVisualState {
  final bool isExpanded;
  final bool isHidden;
  final Color baseColor;
  final Color? highlightColor; // For AI emphasis
  final double highlightIntensity; // For emphasis strength

  final bool canExpand;

  const GanttTaskVisualState({
    this.isExpanded = true,
    this.isHidden = false,
    required this.baseColor,
    this.highlightColor,
    this.highlightIntensity = 0.0,
    this.canExpand = false,
  });

  Color get effectiveColor {
    if (highlightColor != null && highlightIntensity > 0) {
      return Color.lerp(baseColor, highlightColor, highlightIntensity) ??
          baseColor;
    }
    // Could modify color based on expanded state
    return isExpanded ? baseColor : baseColor.withOpacity(0.7);
  }

  GanttTaskVisualState copyWith({
    bool? isExpanded,
    bool? isHidden,
    Color? baseColor,
    Color? highlightColor,
    double? highlightIntensity,
    bool? canExpand,
  }) =>
      GanttTaskVisualState(
        isExpanded: isExpanded ?? this.isExpanded,
        isHidden: isHidden ?? this.isHidden,
        baseColor: baseColor ?? this.baseColor,
        highlightColor: highlightColor ?? this.highlightColor,
        highlightIntensity: highlightIntensity ?? this.highlightIntensity,
        canExpand: canExpand ?? this.canExpand,
      );
}

final ganttTaskVisualStateProvider = StateNotifierProvider.family<
    GanttTaskVisualStateNotifier, GanttTaskVisualState, String>((ref, taskId) {
  return GanttTaskVisualStateNotifier(ref, taskId);
});

class GanttTaskVisualStateNotifier extends StateNotifier<GanttTaskVisualState> {
  final Ref ref;
  final String taskId;

  GanttTaskVisualStateNotifier(this.ref, this.taskId)
      : super(GanttTaskVisualState(
          baseColor: _generateColorFromId(taskId), // Default initial color
          canExpand: false,
        )) {
    // Initialize and listen to dependencies
    _updateVisualState();
    ref.listen(
        taskParentChainIdsProvider(taskId), (_, __) => _updateVisualState());
    ref.listen(
        taskHierarchyInfoProvider(taskId), (_, __) => _updateVisualState());
  }

  void _updateVisualState() {
    final parentChain = ref.read(taskParentChainIdsProvider(taskId));
    final rootParentId = parentChain.isEmpty ? taskId : parentChain.last;
    final newColor = _generateColorFromId(rootParentId);

    final canExpand =
        ref.read(taskHierarchyInfoProvider(taskId))?.childrenIds.isNotEmpty ??
            false;

    state = state.copyWith(
      baseColor: newColor,
      canExpand: canExpand,
    );
  }

  void toggleExpanded() {
    if (!state.canExpand) return; // Only toggle if expansion is possible
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void toggleHidden() {
    state = state.copyWith(isHidden: !state.isHidden);
  }

  void setHighlight(Color? color, [double intensity = 1.0]) {
    state = state.copyWith(
      highlightColor: color,
      highlightIntensity: intensity,
    );
  }

  void clearHighlight() {
    state = state.copyWith(
      highlightColor: null,
      highlightIntensity: 0.0,
    );
  }
}

// Helper function moved from color provider
Color _generateColorFromId(String id) {
  final hash = id.hashCode;
  final hue = (hash % 360).abs().toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.6, 0.6).toColor();
}

// Computed visibility can still be separate since it depends on parent state
final ganttTaskVisibilityProvider =
    Provider.family<bool, String>((ref, taskId) {
  final info = ref.watch(taskHierarchyInfoProvider(taskId));
  final taskState = ref.watch(ganttTaskVisualStateProvider(taskId));

  if (taskState.isHidden) return false;
  if (info?.parentId == null) return true;

  String? currentParentId = info!.parentId;
  while (currentParentId != null) {
    final parentInfo = ref.watch(taskHierarchyInfoProvider(currentParentId));
    final parentState =
        ref.watch(ganttTaskVisualStateProvider(currentParentId));

    if (!parentState.isExpanded || parentState.isHidden) return false;

    currentParentId = parentInfo?.parentId;
  }

  return true;
});
