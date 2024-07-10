import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/i_has_id.dart';
import 'package:seren_ai_flutter/services/data/throw_error_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T item);

class BaseLoaderCacheDatabaseNotifier<T extends IHasId> {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final Map<String, T?> _cache = {};

  BaseLoaderCacheDatabaseNotifier({
    required this.tableName,
    required this.fromJson,
    required this.toJson,
  });

  Future<List<T>> getItems(
      {List<String>? ids, List<Map<String, dynamic>>? eqFilters}) async {
    if (ids == null && eqFilters == null) {
      return [];
    }

    var query = client.from(tableName).select();
    final List<T> items = [];

    if (ids != null) {
      final idsToGet = ids.where((id) => !_cache.containsKey(id)).toList();
      items.addAll(ids
          .where((id) => _cache.containsKey(id))
          .map((id) => _cache[id]!)
          .toList());
      query = query.inFilter('id', idsToGet);

      // If there are no filters, we can return the cached items
      if (idsToGet.isEmpty && eqFilters == null) {
        return items;
      }
    }

    if (eqFilters != null) {
      for (var filter in eqFilters) {
        query = query.eq(filter['key'], filter['value']);
      }
    }

    // Make the request
    final response = await query.end();
    final fetchedItems = (response as List).map((e) => fromJson(e)).toList();
    items.addAll(fetchedItems);

    for (var item in fetchedItems) {
      _cache[item.id] = item;
    }

    return items;
  }

  Future<T?> getItemById(String id,
      {List<Map<String, dynamic>>? eqFilters}) async {
    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    var query = client.from(tableName).select();
    if (eqFilters != null) {
      for (var filter in eqFilters) {
        query = query.eq(filter['key'], filter['value']);
      }
      query = query.eq('id', id);

      final response = await query.single().end();
      final item = fromJson(response);

      _cache[id] = item;
      return item;
    }
    return null;
  }

  Future<T> createItem(T item) async {
    final response = await client.from(tableName).insert(toJson(item)).select().end();
    final newItem = fromJson(response.first);
    _cache[newItem.id] = newItem;
    return newItem;
  }

  Future<void> modifyItem(T item) async {
    await client.from(tableName).upsert(toJson(item)).select().end();
    _cache[item.id] = item;
  }

  Future<void> deleteItem(String id) async {
    await client.from(tableName).delete().eq('id', id).end();
    _cache.remove(id);
  }
}
