import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T item);

/// For retrieving values from a specifi DB table 
/// Use for joined tables where we don't want to recompute joins based on foreign keys 
class BaseReadDb<T extends IHasId> {  
  final String tableName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final PowerSyncDatabase db;

  BaseReadDb({
    required this.db,
    required this.tableName,
    required this.fromJson,
    required this.toJson,
  });

  Future<List<T>> getItems(
      {Iterable<String>? ids, Iterable<Map<String, dynamic>>? eqFilters}) async {
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

    return items;
  }

  Future<T?> getItem(
      {String? id,List<Map<String, dynamic>>? eqFilters}) async {

    if (id == null && eqFilters == null) {
      return null;
    }

    var query = 'SELECT * FROM $tableName';

    if(id != null){
      query += " WHERE id = '$id'";
    }
    
    if (eqFilters != null) {
      query += (id != null) ? ' AND ' : ' WHERE ';
      final filterClauses = eqFilters.map((filter) => "${filter['key']} = '${filter['value']}'");
      query += filterClauses.join(' AND ');
    }

    final response = await db.execute(query);
    final item = fromJson(response.first);
    
    return item;
  }

  Future<T> insertItem(T item) async {
    final response = await db.execute('INSERT INTO $tableName (${toJson(item)})');
    final newItem = fromJson(response.first);
    return newItem;
  }

  Future<void> updateItem(T item) async {
    await db.execute('UPDATE $tableName SET ${toJson(item)} WHERE id = ${item.id}');    
  }

  Future<void> deleteItem(String id) async {
    await db.execute('DELETE FROM $tableName WHERE id = $id');    
  }
}
