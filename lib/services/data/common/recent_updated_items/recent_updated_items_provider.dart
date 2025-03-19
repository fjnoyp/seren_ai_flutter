import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seren_ai_flutter/services/auth/cur_auth_state_provider.dart';
import 'package:seren_ai_flutter/services/data/common/recent_updated_items/date_grouped_items.dart';
import 'package:seren_ai_flutter/services/data/notes/models/note_model.dart';
import 'package:seren_ai_flutter/services/data/notes/repositories/notes_repository.dart';
import 'package:seren_ai_flutter/services/data/orgs/providers/cur_selected_org_id_notifier.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/repositories/tasks_repository.dart';

List<DateGroupedItems> _groupByDate(List<dynamic> items) {
  final groups = <DateTime, List<dynamic>>{};

  for (final item in items) {
    final date =
        (item is TaskModel ? item.updatedAt : (item as NoteModel).updatedAt);
    // If for some reason the date is null, skip the item
    if (date == null) continue;
    final dateOnly = DateTime(date.year, date.month, date.day);

    groups.putIfAbsent(dateOnly, () => []).add(item);
  }

  return groups.entries.map((e) => DateGroupedItems(e.key, e.value)).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

final recentUpdatedItemsProvider =
    StreamProvider<List<DateGroupedItems>>((ref) async* {
  final userValue = ref.watch(curUserProvider).value;
  final orgValue = ref.watch(curSelectedOrgProvider).value;
  final userId = userValue?.id;
  final orgId = orgValue?.id;

  if (userId == null || orgId == null) {
    yield [];
    return;
  }

  final tasksStream = ref
      .watch(tasksRepositoryProvider)
      .watchRecentlyUpdatedTasks(userId: userId, orgId: orgId);
  final notesStream = ref
      .watch(notesRepositoryProvider)
      .watchRecentlyUpdatedNotes(userId: userId);

  await for (final combinedData in Rx.combineLatest2<List<TaskModel>,
      List<NoteModel>, List<DateGroupedItems>>(
    tasksStream,
    notesStream,
    (List<TaskModel> tasks, List<NoteModel> notes) {
      final combined = [...tasks, ...notes];
      combined.sort((a, b) {
        final aDate = a is TaskModel ? a.updatedAt : (a as NoteModel).updatedAt;
        final bDate = b is TaskModel ? b.updatedAt : (b as NoteModel).updatedAt;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });
      return _groupByDate(combined.take(40).toList());
    },
  )) {
    yield combinedData;
  }
});
