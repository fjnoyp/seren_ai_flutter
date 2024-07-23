import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_model.dart';
import 'package:seren_ai_flutter/services/data/tasks/models/task_user_assignments.dart';
import 'package:seren_ai_flutter/services/data/tasks/task_user_assignments_listener_database_provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final curUserTasksListListenerDatabaseProvider =
    StateNotifierProvider<CurUserTasksListNotifier, List<TaskModel>?>((ref) {
  print("Creating CurUserTasksListNotifier provider");

  return CurUserTasksListNotifier(ref);
});


/*

/// Get the current team's tasks
/// TODO: check if can reuse existing DRY code from BaseListenerDatabaseNotifier
/// Can likely make a BaseWatchProviderComp on the TaskUserAssignments and then create this one there
class CurUserTasksListNotifier extends StateNotifier<List<TaskModel>?> {
  final SupabaseClient client = Supabase.instance.client;
  final Ref ref;
  late RealtimeChannel _subscription;

  CurUserTasksListNotifier(this.ref) : super(null) {
init(); 
  }

  void init() {
    print("Creating CurUserTasksListNotifier");

    // Listen to task_user_assignments
    //List<TaskUserAssignments>? taskUserAssignments =
        //ref.watch(taskUserAssignmentsListenerDatabaseProvider);

    final List<TaskUserAssignments> taskUserAssignments = []; 

    // Update the task id list
    if (taskUserAssignments == null) {
      print('CurUserTasksListNotifier: taskUserAssignments is null');
      state = [];
      return;
    }

    // Get the task id list
    List<String> taskIds = taskUserAssignments.map((e) => e.taskId).toList();

    // Use channel listen instead of stream
    _subscription = client
        .channel('public:tasks')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'tasks',
            schema: 'public',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.inFilter,
              column: 'id',
              value: taskIds,
            ),
            callback: (payload, [ref]) {
              final newRecord = payload.newRecord as Map<String, dynamic>;
              final newTask = TaskModel.fromJson(newRecord);

              if (!taskIds.contains(newTask.id)) {
                // TODO: add extra filter due to Supabase bug:
                // https://github.com/supabase/realtime/issues/585
                print('CurUserTasksListNotifier: newTask.id is not in taskIds');
                return;
              }

              print('CurUserTasksListNotifier: newTask: $newTask');
              state = [...?state]
                ..removeWhere((t) => t.id == newTask.id)
                ..add(newTask);
            })
        .subscribe();

    // Initial fetch of tasks
    _fetchInitialTasks(taskIds);
    
  }

  Future<void> _otherFetch(String userId) async {
    final response =
        await client.from('tasks').select().inFilter('assigned_user_id', [userId]);

    print('CurUserTasksListNotifier: _otherFetch: response: $response');
    state = response.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<void> _fetchInitialTasks(List<String> taskIds) async {
    final response =
        await client.from('tasks').select().inFilter('id', ['45ade84b-3d61-4ec4-9a8b-ebcba40e1df8']); //taskIds);

    print('CurUserTasksListNotifier: _fetchInitialTasks: response: $response');
    state = response.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  void dispose() {
    print('CurUserTasksListNotifier: dispose');
    //client.removeChannel(_subscription);
    super.dispose();
  }
}
*/

class CurUserTasksListNotifier extends StateNotifier<List<TaskModel>?> {
  final SupabaseClient client = Supabase.instance.client;
  final Ref ref;
  StreamSubscription? _subscription;

  CurUserTasksListNotifier(this.ref) : super(null) {
    _initialize();
  }

  void _initialize() {

    // PREVIOUS MAJOR ISSUE: 
    // Using ref.watch instead of ref.listen caused thie provider to keep on disposing itself        
    //ref.watch(taskUserAssignmentsListenerDatabaseProvider);

    // I think this was because watch rebuilt the provider when the value updated, but because the provider was scoped to a single taskView UI it was also rebuilding the UI. 

    // Unsure - no online documentation confirms this. Riverpod docs actually tell you to use watch when having providers rely on each other ... 


    ref.listen(taskUserAssignmentsListenerDatabaseProvider, (previous, next) {
      if (next != null) {
        // Get the list of tasks to watch 

        final List<String> taskIds = next.map((e) => e.taskId).toList();

        print('CurUserTasksListNotifier: _initialize: taskIds: $taskIds');

        // TODO must unsubscribe from previous subscription
        client
        .channel('public:tasks')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            table: 'tasks',
            schema: 'public',

            callback: (payload, [ref]) {
              final newRecord = payload.newRecord as Map<String, dynamic>;
              final newTask = TaskModel.fromJson(newRecord);

              if (!taskIds.contains(newTask.id)) {
                // TODO: add extra filter due to Supabase bug:
                // https://github.com/supabase/realtime/issues/585
                print('CurUserTasksListNotifier: newTask.id is not in taskIds');
                return;
              }

              print('CurUserTasksListNotifier: newTask: $newTask');
              state = [...?state]
                ..removeWhere((t) => t.id == newTask.id)
                ..add(newTask);
            })
        .subscribe();


        print('CurUserTasksListNotifier: _initialize: next: $next');

        
        _fetchInitialTasks(taskIds);
      }
    }, fireImmediately: true);
  
  }

  Future<void> _fetchInitialTasks(List<String> taskIds) async {
    final response =
        await client.from('tasks').select().inFilter('id', ['45ade84b-3d61-4ec4-9a8b-ebcba40e1df8']); //taskIds);

    print('CurUserTasksListNotifier: _fetchInitialTasks: response: $response');
    state = response.map((e) => TaskModel.fromJson(e)).toList();
  }
  // ... rest of the methods ...

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}