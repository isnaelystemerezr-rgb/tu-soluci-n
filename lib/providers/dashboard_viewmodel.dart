import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart' as drift;
import '../models/orden.dart';
import '../models/tecnico.dart';

/// Resumen del dashboard: conteo de órdenes abiertas y carga por técnico.
class DashboardState {
  final int ordenesAbiertas;
  final int ordenesRecibidas;
  final int ordenesEnReparacion;
  final int ordenesLista;
  final int ordenesEntregadas;
  final int ordenesCanceladas;
  final Map<int, int> ordenesPorTecnico; // tecnicoId -> cantidad
  final bool cargando;
  final String? error;

  DashboardState({
    required this.ordenesAbiertas,
    required this.ordenesRecibidas,
    required this.ordenesEnReparacion,
    required this.ordenesLista,
    required this.ordenesEntregadas,
    required this.ordenesCanceladas,
    required this.ordenesPorTecnico,
    this.cargando = false,
    this.error,
  });

  DashboardState copyWith({
    int? ordenesAbiertas,
    int? ordenesRecibidas,
    int? ordenesEnReparacion,
    int? ordenesLista,
    int? ordenesEntregadas,
    int? ordenesCanceladas,
    Map<int, int>? ordenesPorTecnico,
    bool? cargando,
    String? error,
  }) {
    return DashboardState(
      ordenesAbiertas: ordenesAbiertas ?? this.ordenesAbiertas,
      ordenesRecibidas: ordenesRecibidas ?? this.ordenesRecibidas,
      ordenesEnReparacion: ordenesEnReparacion ?? this.ordenesEnReparacion,
      ordenesLista: ordenesLista ?? this.ordenesLista,
      ordenesEntregadas: ordenesEntregadas ?? this.ordenesEntregadas,
      ordenesCanceladas: ordenesCanceladas ?? this.ordenesCanceladas,
      ordenesPorTecnico: ordenesPorTecnico ?? this.ordenesPorTecnico,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

class DashboardViewModel extends StateNotifier<DashboardState> {
  final drift.AppDatabase _db;

  DashboardViewModel(this._db)
      : super(const DashboardState(
          ordenesAbiertas: 0,
          ordenesRecibidas: 0,
          ordenesEnReparacion: 0,
          ordenesLista: 0,
          ordenesEntregadas: 0,
          ordenesCanceladas: 0,
          ordenesPorTecnico: {},
        ));

  Future<void> cargarResumen() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final todas = await _db.getAllOrdenes(); // List<drift.Orden>
      int recibidas = 0, enReparacion = 0, lista = 0, entregadas = 0, canceladas = 0;
      final Map<int, int> porTecnico = {};

      for (final o in todas) {
        switch (o.estado) {
          case OrdenEstado.recibida:
            recibidas++;
            break;
          case OrdenEstado.enReparacion:
            enReparacion++;
            break;
          case OrdenEstado.lista:
            lista++;
            break;
          case OrdenEstado.entregada:
            entregadas++;
            break;
          case OrdenEstado.cancelada:
            canceladas++;
            break;
        }
        if (OrdenEstado.esAbierto(o.estado)) {
          if (o.tecnicoId != null) {
            porTecnico[o.tecnicoId!] = (porTecnico[o.tecnicoId!] ?? 0) + 1;
          }
        }
      }

      state = state.copyWith(
        ordenesAbiertas: recibidas + enReparacion + lista,
        ordenesRecibidas: recibidas,
        ordenesEnReparacion: enReparacion,
        ordenesLista: lista,
        ordenesEntregadas: entregadas,
        ordenesCanceladas: canceladas,
        ordenesPorTecnico: porTecnico,
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }
}

final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  final db = ref.watch(drift.appDatabaseProvider);
  return DashboardViewModel(db);
});
