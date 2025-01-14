import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:seren_ai_flutter/services/data/common/i_has_id.dart';

final Logger log = Logger('base-repository');

/// Base class for watching / getting data from the database
/// Does not provide any mutation methods (see service classes for that)
abstract class BaseRepository<T extends IHasId> {
  final PowerSyncDatabase db;

  final String primaryTable;

  const BaseRepository(this.db, {required this.primaryTable});

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson(T item) => item.toJson();

  // TODO p3: check that watch tables are being set correctly
  // Especially since we just removed joined models
  Set<String> get REMOVEwatchTables => {};

  // todo - merge the base table db with the base repostiory
  // turn into a CRUD dedicated class

  Stream<List<T>> watch(String query, Map<String, dynamic> params,
      {Set<String>? triggerOnTables}) {
    return db
        .watch(
      query,
      parameters: params.values.toList(),
      triggerOnTables: triggerOnTables ?? [primaryTable],
    )
        .map((results) {
      try {
        return results.map((row) => fromJson(row)).toList();
      } catch (e, stackTrace) {
        log.severe('Error in BaseRepository.watch for query: $query');
        log.severe('Parameters: $params');
        log.severe('Error: $e');
        log.severe('StackTrace: $stackTrace');
        rethrow; // Rethrow to maintain error propagation
      }
    });
  }

  Stream<T> watchById(String id) {
    return watchSingle('SELECT * FROM $primaryTable WHERE id = ?', {'id': id});
  }

  Future<List<T>> get(String query, Map<String, dynamic> params) async {
    final results = await db.execute(query, params.values.toList());
    return results.map((row) => fromJson(row)).toList();
  }

  Future<T?> getById(String id) async {
    final results =
        await db.execute('SELECT * FROM $primaryTable WHERE id = ?', [id]);
    return results.isNotEmpty ? fromJson(results.first) : null;
  }

  Stream<T> watchSingle(String query, Map<String, dynamic> params,
      {Set<String>? triggerOnTables}) {
    return db
        .watch(
      query,
      parameters: params.values.toList(),
      triggerOnTables: triggerOnTables ?? [primaryTable],
    )
        .map((results) {
      try {
        return fromJson(results.first);
      } catch (e, stackTrace) {
        log.severe('Error in BaseRepository.watchSingle for query: $query');
        log.severe('Parameters: $params');
        log.severe('Error: $e');
        log.severe('StackTrace: $stackTrace');
        rethrow;
      }
    });
  }

  Future<T> getSingle(String query, Map<String, dynamic> params) async {
    final results = await db.execute(query, params.values.toList());
    return fromJson(results.first);
  }

  // TODO p0: TEST and check that this is correctly implemented
  // it should return the id of the created item
  // for the repository to use it to update its fields
  Future<String> insertItem(T item) async {
    final Map<String, dynamic> json = toJson(item);

    final columns = '(${json.keys.join(', ')})';
    final valuesPlaceholder =
        'VALUES(${List.filled(json.keys.length, '?').join(', ')})';
    final values = json.values.toList();
    try {
      final result = await db.execute(
          'INSERT INTO $primaryTable $columns $valuesPlaceholder', values);
      log.info('Inserted item into $primaryTable: $result');
      return result.single['id'];
    } catch (e) {
      throw Exception('Failed to insert item into $primaryTable: $e');
    }
  }

  Future<void> insertItems(List<T> items) async {
    if (items.isEmpty) return;

    final Map<String, dynamic> firstItemJson = toJson(items.first);
    final columns = firstItemJson.keys.join(', ');
    final placeholders = List.filled(firstItemJson.length, '?').join(', ');

    final values = items.map((item) {
      final itemJson = toJson(item);
      return itemJson.values.map(_sqlEscape).toList();
    }).toList();

    await db.executeBatch(
        'INSERT INTO $primaryTable ($columns) VALUES $placeholders', values);
  }

  Future<String> upsertItem(T item) async {
    final existingItem =
        await db.execute('SELECT * FROM $primaryTable WHERE id = ?', [item.id]);
    if (existingItem.isEmpty) {
      return await insertItem(item);
    } else {
      await updateItem(item);
      return item.id;
    }
  }

  Future<void> upsertItems(List<T> items) async {
    for (final item in items) {
      await upsertItem(item);
    }
  }

  Future<void> updateItem(T item) async {
    final Map<String, dynamic> json = toJson(item);
    final setClause = json.entries
        .where((entry) => entry.key != 'id')
        .map((entry) => '${entry.key} = ${_sqlEscape(entry.value)}')
        .join(', ');

    await db.execute(
        'UPDATE $primaryTable SET $setClause WHERE id = ${_sqlEscape(item.id)}');
  }

  Future<void> deleteItem(String id) async {
    await db.execute('DELETE FROM $primaryTable WHERE id = ${_sqlEscape(id)}');
  }

  @protected
  Future<void> updateField(String id, String field, dynamic value) async {
    await db.execute(
        'UPDATE $primaryTable SET $field = ? WHERE id = ?', [value, id]);
  }

  String _sqlEscape(dynamic value) {
    if (value == null) return 'NULL';
    if (value is num) return value.toString();
    if (value is bool) return value ? '1' : '0';
    if (value is DateTime) return "'${value.toIso8601String()}'";
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
