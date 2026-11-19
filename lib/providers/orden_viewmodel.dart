import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart' as drift;
import '../models/orden.dart';
import '../models/repuesto.dart';
import '../models/orden_repuesto.dart';
import '../models/equipo.dart';
import '../models/tecnico.dart';

/// Detalle enriquecido de una orden para la UI.
class OrdenDetalle {
  final Orden orden;
  final Equipo? equipo;
  final Tecnico? tecnico;
  final List<Map<String, dynamic>> repuestosConDetalle; // repuesto + cantidad + subtotal
  final int total;

  OrdenDetalle({
    required this.orden,
    this.equipo,
    this.tecnico,
    required this.repuestosConDetalle,
    required this.total,
  });
}

class OrdenState {
  final List<Orden> ordenes;
  final OrdenDetalle? detalleSeleccionado;
  final bool cargando;
  final String? error;

  OrdenState({
    required this.ordenes,
    this.detalleSeleccionado,
    this.cargando = false,
    this.error,
  });

  OrdenState copyWith({
    List<Orden>? ordenes,
    OrdenDetalle? detalleSeleccionado,
    bool? cargando,
    String? error,
  }) {
    return OrdenState(
      ordenes: ordenes ?? this.ordenes,
      detalleSeleccionado: detalleSeleccionado ?? this.detalleSeleccionado,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

class OrdenViewModel extends StateNotifier<OrdenState> {
  final drift.AppDatabase _db;

  OrdenViewModel(this._db) : super(const OrdenState(ordenes: []));

  // ---------- Carga ----------

  Future<void> cargarOrdenes() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final rows = await _db.getAllOrdenes();
      final ordenes = rows.map((r) => Orden(
        id: r.id,
        estado: r.estado,
        tecnicoId: r.tecnicoId,
        equipoId: r.equipoId,
        manoDeObra: r.manoDeObra,
        fechaCreacion: r.fechaCreacion,
        fechaActualizacion: r.fechaActualizacion,
      )).toList();
      state = state.copyWith(ordenes: ordenes, cargando: false);
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<List<Orden>> cargarOrdenesPorEstado(String estado) async {
    final rows = await _db.getOrdenesByEstado(estado);
    return rows.map((r) => Orden(
      id: r.id,
      estado: r.estado,
      tecnicoId: r.tecnicoId,
      equipoId: r.equipoId,
      manoDeObra: r.manoDeObra,
      fechaCreacion: r.fechaCreacion,
      fechaActualizacion: r.fechaActualizacion,
    )).toList();
  }

  // ---------- CRUD ----------

  Future<int> crearOrden(Orden orden) async {
    final id = await _db.insertOrden(orden.toCompanion());
    await cargarOrdenes();
    return id;
  }

  Future<int> actualizarOrden(Orden orden) async {
    if (orden.id == null) return 0;
    await _db.updateOrden(orden.id!, orden.toCompanion());
    await cargarOrdenes();
    return orden.id!;
  }

  Future<void> eliminarOrden(int id) async {
    await _db.deleteOrden(id);
    await cargarOrdenes();
  }

  // ---------- Reglas de negocio ----------

  /// Cambia el estado de una orden.
  Future<void> cambiarEstado(int ordenId, String nuevoEstado) async {
    if (!OrdenEstado.esValido(nuevoEstado)) {
      state = state.copyWith(error: 'Estado no válido: $nuevoEstado');
      return;
    }
    await _db.cambiarEstadoOrden(ordenId, nuevoEstado);
    await cargarOrdenes();
    if (state.detalleSeleccionado?.orden.id == ordenId) {
      await cargarDetalle(ordenId);
    }
  }

  /// Asigna (o quita) el técnico responsable de la orden.
  Future<void> asignarTecnico(int ordenId, int? tecnicoId) async {
    await _db.asignarTecnicoOrden(ordenId, tecnicoId);
    await cargarOrdenes();
    if (state.detalleSeleccionado?.orden.id == ordenId) {
      await cargarDetalle(ordenId);
    }
  }

  /// Añade/actualiza el costo de mano de obra.
  Future<void> agregarManoDeObra(int ordenId, int monto) async {
    await _db.actualizarManoDeObra(ordenId, monto);
    await cargarOrdenes();
    if (state.detalleSeleccionado?.orden.id == ordenId) {
      await cargarDetalle(ordenId);
    }
  }

  /// Agrega un repuesto a la orden y descuenta automáticamente del inventario.
  Future<void> agregarRepuestoAOrden(int ordenId, int repuestoId, int cantidad) async {
    final repuesto = await _db.getRepuesto(repuestoId);
    if (repuesto == null) {
      state = state.copyWith(error: 'Repuesto no encontrado');
      return;
    }
    if (repuesto.existencias < cantidad) {
      state = state.copyWith(error: 'Stock insuficiente (disponible: ${repuesto.existencias})');
      return;
    }

    // Registrar en la tabla intermedia
    await _db.insertOrdenRepuesto(drift.OrdenRepuestosCompanion(
      ordenId: Value(ordenId),
      repuestoId: Value(repuestoId),
      cantidad: Value(cantidad),
    ));

    // Descontar stock
    await _db.descontarStock(repuestoId, cantidad);

    await cargarOrdenes();
    if (state.detalleSeleccionado?.orden.id == ordenId) {
      await cargarDetalle(ordenId);
    }
  }

  /// Quita un repuesto de la orden y devuelve el stock.
  Future<void> quitarRepuestoDeOrden(int ordenRepuestoId, int repuestoId, int cantidad) async {
    await _db.deleteOrdenRepuesto(ordenRepuestoId);
    await _db.devolverStock(repuestoId, cantidad);
    await cargarOrdenes();
    if (state.detalleSeleccionado?.orden.id != null) {
      await cargarDetalle(state.detalleSeleccionado!.orden.id!);
    }
  }

  // ---------- Detalle ----------

  Future<void> cargarDetalle(int ordenId) async {
    final orden = await _db.getOrden(ordenId);
    if (orden == null) return;

    Equipo? equipo;
    final equipoRow = await _db.getEquipo(orden.equipoId);
    if (equipoRow != null) {
      equipo = Equipo(
        id: equipoRow.id,
        tipo: equipoRow.tipo,
        marca: equipoRow.marca,
        modelo: equipoRow.modelo,
        numeroSerie: equipoRow.numeroSerie,
        fallaReportada: equipoRow.fallaReportada,
        clienteId: equipoRow.clienteId,
      );
    }

    Tecnico? tecnico;
    if (orden.tecnicoId != null) {
      final tRow = await _db.getTecnico(orden.tecnicoId!);
      if (tRow != null) {
        tecnico = Tecnico(id: tRow.id, nombre: tRow.nombre, especialidad: tRow.especialidad);
      }
    }

    final repuestosRows = await _db.getRepuestosDeOrden(ordenId);
    final List<Map<String, dynamic>> repuestosConDetalle = [];
    int totalRepuestos = 0;

    for (final or in repuestosRows) {
      final r = await _db.getRepuesto(or.repuestoId);
      if (r == null) continue;
      final subtotal = or.cantidad * r.precio;
      totalRepuestos += subtotal;
      repuestosConDetalle.add({
        'ordenRepuestoId': or.id,
        'repuestoId': r.id,
        'nombre': r.nombre,
        'codigo': r.codigo,
        'cantidad': or.cantidad,
        'precioUnitario': r.precio,
        'subtotal': subtotal,
      });
    }

    final total = orden.manoDeObra + totalRepuestos;

    state = state.copyWith(
      detalleSeleccionado: OrdenDetalle(
        orden: Orden(
          id: orden.id,
          estado: orden.estado,
          tecnicoId: orden.tecnicoId,
          equipoId: orden.equipoId,
          manoDeObra: orden.manoDeObra,
          fechaCreacion: orden.fechaCreacion,
          fechaActualizacion: orden.fechaActualizacion,
          repuestosUsados: repuestosRows.map((or) => OrdenRepuesto(
            id: or.id,
            ordenId: or.ordenId,
            repuestoId: or.repuestoId,
            cantidad: or.cantidad,
          )).toList(),
          total: total.toDouble(),
        ),
        equipo: equipo,
        tecnico: tecnico,
        repuestosConDetalle: repuestosConDetalle,
        total: total,
      ),
    );
  }

  void limpiarDetalle() {
    state = state.copyWith(detalleSeleccionado: null);
  }
}

extension _OrdenCompanion on Orden {
  drift.OrdenesCompanion toCompanion() => drift.OrdenesCompanion(
        estado: Value(estado),
        tecnicoId: Value(tecnicoId),
        equipoId: Value(equipoId),
        manoDeObra: Value(manoDeObra),
        fechaCreacion: Value(fechaCreacion),
        fechaActualizacion: Value(fechaActualizacion),
      );
}

extension _OrdenRepuestoCompanion on OrdenRepuesto {
  drift.OrdenRepuestosCompanion toCompanion() => drift.OrdenRepuestosCompanion(
        ordenId: Value(ordenId),
        repuestoId: Value(repuestoId),
        cantidad: Value(cantidad),
      );
}

final ordenViewModelProvider = StateNotifierProvider<OrdenViewModel, OrdenState>((ref) {
  final db = ref.watch(drift.appDatabaseProvider);
  return OrdenViewModel(db);
});
