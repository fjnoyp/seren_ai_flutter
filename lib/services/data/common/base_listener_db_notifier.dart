import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seren_ai_flutter/services/data/db_setup/db_provider.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class BaseListenerDbParams<T> {
  final String tableName;
  final List<Map<String, dynamic>> filters;
  final FromJson<T> fromJson;

  BaseListenerDbParams({required this.tableName, required this.filters, required this.fromJson});
}

/// Listen to the database for changes and auto updates state.
class BaseListenerDbNotifier<T>
    extends FamilyNotifier<List<T>?, BaseListenerDbParams<T>> {
  BaseListenerDbNotifier();

  @override
  List<T>? build(BaseListenerDbParams<T> arg) {
    final tableName = arg.tableName;
    final eqFilters = arg.filters;
    final fromJson = arg.fromJson;

    final db = ref.read(dbProvider);

    final whereClause =
        eqFilters.map((filter) => "${filter['key']} = ?").join(" AND ");
    final query = "SELECT * FROM $tableName WHERE $whereClause";

    final subscription = db.watch(query).listen((results) {
      List<T> items = results.map((e) => fromJson(e)).toList();
      state = items;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return null;
  }

  Future<T> createItem(T item, Map<String, dynamic> Function(T) toJson) async {
    final db = ref.read(dbProvider);
    final tableName = arg.tableName;

    await db.execute(
        'INSERT INTO $tableName (${toJson(item).keys.join(',')}) VALUES (${toJson(item).values.join(',')})');
    return item;
  }

  Future<void> modifyItem(
      T item, Map<String, dynamic> Function(T) toJson) async {
    final db = ref.read(dbProvider);
    final tableName = arg.tableName;

    await db.execute(
        'UPDATE $tableName SET ${toJson(item).keys.join(',')}) VALUES (${toJson(item).values.join(',')})');
  }

  Future<void> deleteItem(String id) async {
    final db = ref.read(dbProvider);
    final tableName = arg.tableName;

    await db.execute('DELETE FROM $tableName WHERE id = ?', [id]);
  }
}
