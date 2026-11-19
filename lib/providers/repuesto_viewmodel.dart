import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart' as drift;
import '../models/repuesto.dart';

class RepuestoState {
  final List<Repuesto> repuestos;
  final List<Repuesto> stockBajo;
  final bool cargando;
  final String? error;

  RepuestoState({
    required this.repuestos,
    required this.stockBajo,
    this.cargando = false,
    this.error,
  });

  RepuestoState copyWith({
    List<Repuesto>? repuestos,
    List<Repuesto>? stockBajo,
    bool? cargando,
    String? error,
  }) {
    return RepuestoState(
      repuestos: repuestos ?? this.repuestos,
      stockBajo: stockBajo ?? this.stockBajo,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

class RepuestoViewModel extends StateNotifier<RepuestoState> {
  final drift.AppDatabase _db;

  RepuestoViewModel(this._db) : super(const RepuestoState(repuestos: [], stockBajo: []));

  Future<void> cargarRepuestos() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final rows = await _db.getAllRepuestos();
      final repuestos = rows.map((r) => Repuesto(
        id: r.id,
        nombre: r.nombre,
        codigo: r.codigo,
        precio: r.precio,
        existencias: r.existencias,
      )).toList();
      final bajo = repuestos.where((r) => r.stockBajo).toList();
      state = state.copyWith(repuestos: repuestos, stockBajo: bajo, cargando: false);
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<int> crearRepuesto(Repuesto repuesto) async {
    final id = await _db.insertRepuesto(repuesto.toCompanion());
    await cargarRepuestos();
    return id;
  }

  Future<int> actualizarRepuesto(Repuesto repuesto) async {
    if (repuesto.id == null) return 0;
    await _db.updateRepuesto(repuesto.id!, repuesto.toCompanion());
    await cargarRepuestos();
    return repuesto.id!;
  }

  Future<void> eliminarRepuesto(int id) async {
    await _db.deleteRepuesto(id);
    await cargarRepuestos();
  }

  /// Ajusta existencias (positivo = entrada, negativo = salida).
  Future<void> ajustarExistencias(int id, int delta) async {
    final actual = await _db.getRepuesto(id);
    if (actual == null) return;
    final nuevo = (actual.existencias + delta).clamp(0, int.max);
    await _db.updateRepuesto(id, drift.RepuestosCompanion(existencias: Value(nuevo)));
    await cargarRepuestos();
  }
}

extension _RepuestoCompanion on Repuesto {
  drift.RepuestosCompanion toCompanion() => drift.RepuestosCompanion(
        nombre: Value(nombre),
        codigo: Value(codigo),
        precio: Value(precio),
        existencias: Value(existencias),
      );
}

final repuestoViewModelProvider = StateNotifierProvider<RepuestoViewModel, RepuestoState>((ref) {
  final db = ref.watch(drift.appDatabaseProvider);
  return RepuestoViewModel(db);
});
