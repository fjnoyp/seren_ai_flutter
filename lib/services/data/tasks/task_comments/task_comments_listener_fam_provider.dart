import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_comments_model.dart';

final taskCommentsListenerFamProvider = NotifierProvider.family<
    TaskCommentsListenerFamNotifier,
    List<TaskCommentsModel>?,
    String>(TaskCommentsListenerFamNotifier.new);

class TaskCommentsListenerFamNotifier
    extends FamilyNotifier<List<TaskCommentsModel>?, String> {
  TaskCommentsListenerFamNotifier();

  @override
  List<TaskCommentsModel>? build(String arg) {
    final taskId = arg;

    final db = ref.read(dbProvider);
    final query =
        "SELECT * FROM task_comments WHERE parent_task_id = '$taskId' ORDER BY created_at DESC";

    final subscription = db.watch(query).listen((results) {
      log('results: $results');
      List<TaskCommentsModel> items =
          results.map((e) => TaskCommentsModel.fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }
}
