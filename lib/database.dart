import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Tablas (Drift)
// ---------------------------------------------------------------------------

class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get telefono => text().withLength(min: 1, max: 30)();

  @override
  Set<Column> get primaryKey => {id};
}

class Equipos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()(); // celular, tablet, laptop
  TextColumn get marca => text().withLength(min: 1, max: 50)();
  TextColumn get modelo => text().withLength(min: 1, max: 50)();
  TextColumn get numeroSerie => text().withLength(min: 1, max: 100)();
  TextColumn get fallaReportada => text().withLength(min: 1, max: 300)();
  IntColumn get clienteId => integer().nullable().references(Clientes, onDelete: OnDelete.cascade)();

  @override
  Set<Column> get primaryKey => {id};
}

class Tecnicos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get especialidad => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Ordenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get estado => text()(); // recibida, en_reparacion, lista, entregada, cancelada
  IntColumn? get tecnicoId => integer().nullable().references(Tecnicos, onDelete: OnDelete.setNull)();
  IntColumn get equipoId => integer().references(Equipos)();
  IntColumn get manoDeObra => integer().withDefault(Constant(0))();
  DateTimeColumn get fechaCreacion => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn? get fechaActualizacion => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Repuestos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get codigo => text().withLength(min: 1, max: 50)();
  IntColumn get precio => integer()(); // precio unitario
  IntColumn get existencias => integer().withDefault(Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class OrdenRepuestos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ordenId => integer().references(Ordenes, onDelete: OnDelete.cascade)();
  IntColumn get repuestoId => integer().references(Repuestos)();
  IntColumn get cantidad => integer().withDefault(Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Base de datos Drift
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Clientes, Equipos, Tecnicos, Ordenes, Repuestos, OrdenRepuestos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // -------- Clientes --------
  Future<List<Cliente>> getAllClientes() => select(clientes).get();
  Future<int> insertCliente(ClientesCompanion cliente) => into(clientes).insert(cliente);
  Future<int> updateCliente(int id, ClientesCompanion cliente) =>
      (update(clientes)..where((c) => c.id.equals(id))).write(cliente);
  Future<int> deleteCliente(int id) => (delete(clientes)..where((c) => c.id.equals(id))).go();
  Future<Cliente?> getCliente(int id) => (select(clientes)..where((c) => c.id.equals(id))).getSingleOrNull();

  // -------- Equipos --------
  Future<List<Equipo>> getAllEquipos() => select(equipos).get();
  Future<List<Equipo>> getEquiposByCliente(int clienteId) =>
      (select(equipos)..where((e) => e.clienteId.equals(clienteId))).get();
  Future<int> insertEquipo(EquiposCompanion equipo) => into(equipos).insert(equipo);
  Future<int> updateEquipo(int id, EquiposCompanion equipo) =>
      (update(equipos)..where((e) => e.id.equals(id))).write(equipo);
  Future<int> deleteEquipo(int id) => (delete(equipos)..where((e) => e.id.equals(id))).go();
  Future<Equipo?> getEquipo(int id) => (select(equipos)..where((e) => e.id.equals(id))).getSingleOrNull();

  // -------- Técnicos --------
  Future<List<Tecnico>> getAllTecnicos() => select(tecnicos).get();
  Future<int> insertTecnico(TecnicosCompanion tecnico) => into(tecnicos).insert(tecnico);
  Future<Tecnico?> getTecnico(int id) => (select(tecnicos)..where((t) => t.id.equals(id))).getSingleOrNull();

  // -------- Órdenes --------
  Future<List<Orden>> getAllOrdenes() => select(ordenes).get();
  Stream<List<Orden>> watchAllOrdenes() => select(ordenes).watch();
  Future<List<Orden>> getOrdenesByEstado(String estado) =>
      (select(ordenes)..where((o) => o.estado.equals(estado))).get();
  Future<List<Orden>> getOrdenesByTecnico(int tecnicoId) =>
      (select(ordenes)..where((o) => o.tecnicoId.equals(tecnicoId))).get();
  Future<int> insertOrden(OrdenesCompanion orden) => into(ordenes).insert(orden);
  Future<int> updateOrden(int id, OrdenesCompanion orden) =>
      (update(ordenes)..where((o) => o.id.equals(id))).write(orden);
  Future<int> deleteOrden(int id) => (delete(ordenes)..where((o) => o.id.equals(id))).go();
  Future<Orden?> getOrden(int id) => (select(ordenes)..where((o) => o.id.equals(id))).getSingleOrNull();
  Future<int> cambiarEstadoOrden(int id, String nuevoEstado) {
    return (update(ordenes)..where((o) => o.id.equals(id)))
        .write(OrdenesCompanion(
          estado: Value(nuevoEstado),
          fechaActualizacion: Value(DateTime.now()),
        ));
  }
  Future<int> asignarTecnicoOrden(int id, int? tecnicoId) {
    return (update(ordenes)..where((o) => o.id.equals(id)))
        .write(OrdenesCompanion(
          tecnicoId: Value(tecnicoId),
          fechaActualizacion: Value(DateTime.now()),
        ));
  }
  Future<int> actualizarManoDeObra(int id, int monto) {
    return (update(ordenes)..where((o) => o.id.equals(id)))
        .write(OrdenesCompanion(
          manoDeObra: Value(monto),
          fechaActualizacion: Value(DateTime.now()),
        ));
  }

  // -------- Repuestos --------
  Future<List<Repuesto>> getAllRepuestos() => select(repuestos).get();
  Future<List<Repuesto>> getRepuestosStockBajo({int umbral = 3}) =>
      (select(repuestos)..where((r) => r.existencias.lessOrEqual(umbral))).get();
  Future<int> insertRepuesto(RepuestosCompanion repuesto) => into(repuestos).insert(repuesto);
  Future<int> updateRepuesto(int id, RepuestosCompanion repuesto) =>
      (update(repuestos)..where((r) => r.id.equals(id))).write(repuesto);
  Future<int> deleteRepuesto(int id) => (delete(repuestos)..where((r) => r.id.equals(id))).go();
  Future<Repuesto?> getRepuesto(int id) => (select(repuestos)..where((r) => r.id.equals(id))).getSingleOrNull();

  /// Descuenta stock de un repuesto tras usarlo en una orden.
  Future<int> descontarStock(int repuestoId, int cantidad) async {
    final actual = await getRepuesto(repuestoId);
    if (actual == null) return 0;
    final nuevo = ((actual.existencias - cantidad).clamp(0, int.max));
    return (update(repuestos)..where((r) => r.id.equals(repuestoId)))
        .write(RepuestosCompanion(existencias: Value(nuevo)));
  }

  /// Devuelve stock tras quitar un repuesto de una orden.
  Future<int> devolverStock(int repuestoId, int cantidad) async {
    final actual = await getRepuesto(repuestoId);
    if (actual == null) return 0;
    final nuevo = actual.existencias + cantidad;
    return (update(repuestos)..where((r) => r.id.equals(repuestoId)))
        .write(RepuestosCompanion(existencias: Value(nuevo)));
  }

  // -------- OrdenRepuestos (intermedio) --------
  Future<List<OrdenRepuesto>> getAllOrdenRepuestos() => select(ordenRepuestos).get();
  Future<List<OrdenRepuesto>> getRepuestosDeOrden(int ordenId) =>
      (select(ordenRepuestos)..where((or) => or.ordenId.equals(ordenId))).get();
  Future<int> insertOrdenRepuesto(OrdenRepuestosCompanion or) => into(ordenRepuestos).insert(or);
  Future<int> deleteOrdenRepuesto(int id) =>
      (delete(ordenRepuestos)..where((or) => or.id.equals(id))).go();

  // -------- Historial --------
  Future<List<Equipo>> buscarEquiposPorSerie(String numeroSerie) =>
      (select(equipos)..where((e) => e.numeroSerie.contains(numeroSerie))).get();

  Future<List<Orden>> ordenesPorEquipo(int equipoId) =>
      (select(ordenes)..where((o) => o.equipoId.equals(equipoId))).get();

  Future<List<Orden>> ordenesPorCliente(int clienteId) =>
      (select(ordenes)
            ..where((o) => o.equipoId.in(
                select(equipos)..where((e) => e.clienteId.equals(clienteId))..map((e) => e.id)))
          ).get();
}

// ---------------------------------------------------------------------------
// Conexión perezosa (una sola instancia)
// ---------------------------------------------------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tu_solution.db'));
    return NativeDatabase(file);
  });
}
