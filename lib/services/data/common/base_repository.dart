import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';

final Logger log = Logger('base-repository');

/// Base class for watching / getting data from the database
/// Does not provide any mutation methods (see service classes for that)
abstract class BaseRepository<T> {

  final PowerSyncDatabase db;

  const BaseRepository(this.db);

  T fromJson(Map<String, dynamic> json);

  Set<String> get watchTables;

  Stream<List<T>> watch(String query, Map<String, dynamic> params) {
    return db
        .watch(
          query,
          parameters: params.values.toList(),
          triggerOnTables: watchTables,
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

  Future<List<T>> get(String query, Map<String, dynamic> params) async {
    final results = await db.execute(query, params.values.toList());
    return results.map((row) => fromJson(row)).toList();
  }

  Stream<T> watchSingle(String query, Map<String, dynamic> params) {
    return db
        .watch(
          query,
          parameters: params.values.toList(),
          triggerOnTables: watchTables,
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
}
