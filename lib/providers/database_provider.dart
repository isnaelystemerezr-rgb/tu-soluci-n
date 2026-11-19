import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database.dart';

part 'database_provider.g.dart';

/// Proveedor de la instancia única de la base de datos Drift.
/// Se cierra automáticamente cuando el provider se descarta.
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}
