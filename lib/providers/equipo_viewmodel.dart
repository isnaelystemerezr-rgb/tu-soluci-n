import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart' as drift;
import '../models/equipo.dart';

class EquipoState {
  final List<Equipo> equipos;
  final bool cargando;
  final String? error;

  EquipoState({required this.equipos, this.cargando = false, this.error});

  EquipoState copyWith({List<Equipo>? equipos, bool? cargando, String? error}) {
    return EquipoState(
      equipos: equipos ?? this.equipos,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

class EquipoViewModel extends StateNotifier<EquipoState> {
  final drift.AppDatabase _db;

  EquipoViewModel(this._db) : super(const EquipoState(equipos: []));

  Future<void> cargarEquipos() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final rows = await _db.getAllEquipos();
      state = state.copyWith(
        equipos: rows.map((r) => Equipo(
          id: r.id,
          tipo: r.tipo,
          marca: r.marca,
          modelo: r.modelo,
          numeroSerie: r.numeroSerie,
          fallaReportada: r.fallaReportada,
          clienteId: r.clienteId,
        )).toList(),
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<List<Equipo>> cargarEquiposPorCliente(int clienteId) async {
    final rows = await _db.getEquiposByCliente(clienteId);
    return rows.map((r) => Equipo(
      id: r.id,
      tipo: r.tipo,
      marca: r.marca,
      modelo: r.modelo,
      numeroSerie: r.numeroSerie,
      fallaReportada: r.fallaReportada,
      clienteId: r.clienteId,
    )).toList();
  }

  Future<int> crearEquipo(Equipo equipo) async {
    final id = await _db.insertEquipo(equipo.toCompanion());
    await cargarEquipos();
    return id;
  }

  Future<int> actualizarEquipo(Equipo equipo) async {
    if (equipo.id == null) return 0;
    await _db.updateEquipo(equipo.id!, equipo.toCompanion());
    await cargarEquipos();
    return equipo.id!;
  }

  Future<void> eliminarEquipo(int id) async {
    await _db.deleteEquipo(id);
    await cargarEquipos();
  }
}

extension _EquipoCompanion on Equipo {
  drift.EquiposCompanion toCompanion() => drift.EquiposCompanion(
        tipo: Value(tipo),
        marca: Value(marca),
        modelo: Value(modelo),
        numeroSerie: Value(numeroSerie),
        fallaReportada: Value(fallaReportada),
        clienteId: Value(clienteId),
      );
}

final equipoViewModelProvider = StateNotifierProvider<EquipoViewModel, EquipoState>((ref) {
  final db = ref.watch(drift.appDatabaseProvider);
  return EquipoViewModel(db);
});
