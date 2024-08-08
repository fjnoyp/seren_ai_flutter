import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T item);

class BaseTableDb<T extends IHasId> {
  final String tableName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final PowerSyncDatabase db;

  BaseTableDb({
    required this.db,
    required this.tableName,
    required this.fromJson,
    required this.toJson,
  }); 

  // refactor using: https://github.com/powersync-ja/powersync.dart/blob/master/packages/powersync/example/batch_writes.dart

  Future<void> insertItem(T item) async {
    final Map<String, dynamic> json = toJson(item);

    final columns = '(${json.keys.join(', ')})';
    final valuesPlaceholder = 'VALUES(${List.filled(json.keys.length, '?').join(', ')})';
    final values = json.values.toList();
    try {
      final result = await db.execute('INSERT INTO $tableName $columns $valuesPlaceholder', values);
    } catch (e) {
      throw Exception('Failed to insert item into $tableName: $e');
    }

    //final values = '(${json.values.map(_sqlEscape).join(', ')})';
    
    /*
    final columns = json.keys.join(', ');
    final values = json.values.map(_sqlEscape).join(', dW');
    
    await db.execute('INSERT INTO $tableName ($columns) VALUES ($values)');
    */
  }

  Future<void> upsertItem(T item) async {
    final existingItem = await db.execute('SELECT * FROM $tableName WHERE id = ?', [item.id]);
    if (existingItem.isEmpty) {
      await insertItem(item);
    } else {
      await updateItem(item);
    }
  }

  Future<void> upsertItems(List<T> items) async {
    for (final item in items) {
      await upsertItem(item);
    }
  }

  Future<void> insertItems(List<T> items) async {
    if (items.isEmpty) return;
    
    final Map<String, dynamic> firstItemJson = toJson(items.first);
    final columns = firstItemJson.keys.join(', ');
    
    final values = items.map((item) {
      final itemJson = toJson(item);
      return '(${itemJson.values.map(_sqlEscape).join(', ')})';
    }).join(', ');
    
    await db.executeBatch('INSERT INTO $tableName ($columns) VALUES $values', []);
  }

  Future<void> updateItem(T item) async {
    final Map<String, dynamic> json = toJson(item);
    final setClause = json.entries
        .where((entry) => entry.key != 'id')
        .map((entry) => '${entry.key} = ${_sqlEscape(entry.value)}')
        .join(', ');
    
    await db.execute('UPDATE $tableName SET $setClause WHERE id = ${_sqlEscape(item.id)}');
  }

  Future<void> deleteItem(String id) async {
    await db.execute('DELETE FROM $tableName WHERE id = ${_sqlEscape(id)}');
  }

  String _sqlEscape(dynamic value) {
    if (value == null) return 'NULL';
    if (value is num) return value.toString();
    if (value is bool) return value ? '1' : '0';
    if (value is DateTime) return "'${value.toIso8601String()}'";
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}