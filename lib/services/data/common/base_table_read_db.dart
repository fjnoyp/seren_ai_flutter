import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/base_table_db.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T item);

/// For retrieving values from a specifi DB table
/// Use for joined tables where we don't want to recompute joins based on foreign keys

// TODO p3: refactor to using queries
// And using futureProvider to fetch data once and not over and over again ...

class BaseTableReadDb<T extends IHasId> extends BaseTableDb<T> {
  final String tableName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final PowerSyncDatabase db;

  BaseTableReadDb({
    required this.db,
    required this.tableName,
    required this.fromJson,
    required this.toJson,
  }) : super(db: db, tableName: tableName, fromJson: fromJson, toJson: toJson);

  Future<List<T>> getItems(
      {Iterable<String>? ids,
      Iterable<Map<String, dynamic>>? eqFilters}) async {
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

      final filterClauses =
          eqFilters.map((filter) => "${filter['key']} = '${filter['value']}'");
      query += filterClauses.join(' AND ');
    }

    // Make the request
    final response = await db.execute(query);
    final fetchedItems = (response as List).map((e) => fromJson(e)).toList();
    items.addAll(fetchedItems);

    return items;
  }

  Future<T?> getItem(
      {String? id, List<Map<String, dynamic>>? eqFilters}) async {
    if (id == null && eqFilters == null) {
      return null;
    }

    var query = 'SELECT * FROM $tableName';

    if (id != null) {
      query += " WHERE id = '$id'";
    }

    if (eqFilters != null) {
      query += (id != null) ? ' AND ' : ' WHERE ';
      final filterClauses =
          eqFilters.map((filter) => "${filter['key']} = '${filter['value']}'");
      query += filterClauses.join(' AND ');
    }

    final response = await db.execute(query);

    if (response.isEmpty) {
      return null;
    }

    final item = fromJson(response.first);

    return item;
  }
}
