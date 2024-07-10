import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/throw_error_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class BaseListenerDatabaseParams {
  final String tableName;
  final List<Map<String, dynamic>> filters;
  final FromJson fromJson;

  BaseListenerDatabaseParams(this.tableName, this.filters, this.fromJson);
}

class BaseListenerDatabaseNotifier<T> extends StateNotifier<List<T>> {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName;
  final List<Map<String, dynamic>> eqFilters;
  final FromJson<T> fromJson;

  BaseListenerDatabaseNotifier({
    required this.tableName,
    required this.eqFilters,
    required this.fromJson,
  }) : super([]) {
    // TODO: realtime updated not working locally - check with deploy 
    // Simple stream test on orgs with realtime enabled does trigger

    SupabaseStreamFilterBuilder query =
        client.from(tableName).stream(primaryKey: ['id']);

    for (var filter in eqFilters) {
      query = query.eq(filter['key'], filter['value'])
          as SupabaseStreamFilterBuilder;
    }

    query.listen((response) {
      List<T> items;
      items = response.map((e) => fromJson(e)).toList();
      state = items;
    });
  }

  Future<T> createItem(T item, Map<String, dynamic> Function(T) toJson) async {
    final response =
        await client.from(tableName).insert(toJson(item)).select().end();
    return fromJson(response.first);
  }

  Future<void> modifyItem(
      T item, Map<String, dynamic> Function(T) toJson) async {
    await client.from(tableName).upsert(toJson(item)).select().end();
  }

  Future<void> deleteItem(String id) async {
    await client.from(tableName).delete().eq('id', id).end();
  }
}
