import 'package:seren_ai_flutter/services/data/tasks/models/joined_task_model.dart';

sealed class CurTaskState {}

class InitialCurTaskState extends CurTaskState {}

class LoadingCurTaskState extends CurTaskState {}

class LoadedCurTaskState extends CurTaskState {
  final JoinedTaskModel task;

  LoadedCurTaskState(this.task);
}

class EmptyCurTaskState extends CurTaskState {}

class ErrorCurTaskState extends CurTaskState {
  final String error;

  ErrorCurTaskState({required this.error});
}
