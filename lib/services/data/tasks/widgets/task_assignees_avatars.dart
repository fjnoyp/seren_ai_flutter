import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/users/providers/task_assigned_users_stream_provider.dart';
import 'package:seren_ai_flutter/services/data/users/widgets/user_avatar.dart';

class TaskAssigneesAvatars extends ConsumerWidget {
  final String taskId;

  const TaskAssigneesAvatars(
    this.taskId, {
    super.key,
    this.avatarsToShow = 3,
    this.avatarRadius = 14.0,
    this.avatarSpacing = 16.0,
  });

  final int avatarsToShow;
  final double avatarRadius;
  final double avatarSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAssignees =
        ref.watch(taskAssignedUsersStreamProvider(taskId)).value ?? [];

    final centerFactor = (avatarsToShow -
            min(taskAssignees.length, avatarsToShow) +
            (taskAssignees.length > avatarsToShow ? 2 : 1)) /
        2;

    return SizedBox(
      height: avatarRadius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(
            min(taskAssignees.length, avatarsToShow),
            (index) => Positioned(
              left: (index + centerFactor) * avatarSpacing,
              child: UserAvatar(taskAssignees[index], radius: avatarRadius),
            ),
          ),
          if (taskAssignees.length > avatarsToShow)
            Positioned(
              left: avatarsToShow * avatarSpacing,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Text('+${taskAssignees.length - avatarsToShow}'),
              ),
            ),
        ],
      ),
    );
  }
}
