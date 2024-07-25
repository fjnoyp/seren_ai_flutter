import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T item);

/// Use cautiously, data does not get updated automatically. 
class BaseCacherDb<T extends IHasId> {  
  final String tableName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final Map<String, T?> _cache = {};
  final PowerSyncDatabase db;

  BaseCacherDb({
    required this.db,
    required this.tableName,
    required this.fromJson,
    required this.toJson,
  });

  Future<List<T>> getItems(
      {List<String>? ids, List<Map<String, dynamic>>? eqFilters}) async {
    if (ids == null && eqFilters == null) {
      return [];
    }

    var query = 'SELECT * FROM $tableName';
    final List<T> items = [];

    if (ids != null) {
      query += " WHERE id IN ('${ids.join("', '")}')";      
    }

    if (eqFilters != null) {
      query += (ids != null) ? ' AND ' : ' WHERE ';

      final filterClauses = eqFilters.map((filter) => "${filter['key']} = '${filter['value']}'");
      query += filterClauses.join(' AND ');
    }

    // Make the request
    final response = await db.execute(query);
    final fetchedItems = (response as List).map((e) => fromJson(e)).toList();
    items.addAll(fetchedItems);

    for (var item in fetchedItems) {
      _cache[item.id] = item;
    }

    return items;
  }

  Future<T?> getItem(
      {String? id,List<Map<String, dynamic>>? eqFilters}) async {

    if (id == null && eqFilters == null) {
      return null;
    }

    var query = 'SELECT * FROM $tableName';

    if(id != null){
      if (_cache.containsKey(id)) {
        return _cache[id];
      }
      query += " WHERE id = '$id'";
    }
    
    if (eqFilters != null) {
      query += (id != null) ? ' AND ' : ' WHERE ';
      final filterClauses = eqFilters.map((filter) => "${filter['key']} = '${filter['value']}'");
      query += filterClauses.join(' AND ');
    }

    final response = await db.execute(query);
    final item = fromJson(response.first);

    _cache[item.id] = item;
    
    return item;
  }

  Future<T> createItem(T item) async {
    final response = await db.execute('INSERT INTO $tableName (${toJson(item)})');
    final newItem = fromJson(response.first);
    _cache[newItem.id] = newItem;
    return newItem;
  }

  Future<void> modifyItem(T item) async {
    await db.execute('UPDATE $tableName SET ${toJson(item)} WHERE id = ${item.id}');
    _cache[item.id] = item;
  }

  Future<void> deleteItem(String id) async {
    await db.execute('DELETE FROM $tableName WHERE id = $id');
    _cache.remove(id);
  }
}
