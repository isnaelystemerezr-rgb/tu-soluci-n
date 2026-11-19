import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart' as drift;
import '../models/tecnico.dart';

class TecnicoState {
  final List<Tecnico> tecnicos;
  final bool cargando;
  final String? error;

  TecnicoState({required this.tecnicos, this.cargando = false, this.error});

  TecnicoState copyWith({List<Tecnico>? tecnicos, bool? cargando, String? error}) {
    return TecnicoState(
      tecnicos: tecnicos ?? this.tecnicos,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

class TecnicoViewModel extends StateNotifier<TecnicoState> {
  final drift.AppDatabase _db;

  TecnicoViewModel(this._db) : super(const TecnicoState(tecnicos: []));

  Future<void> cargarTecnicos() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final rows = await _db.getAllTecnicos();
      state = state.copyWith(
        tecnicos: rows.map((r) => Tecnico(id: r.id, nombre: r.nombre, especialidad: r.especialidad)).toList(),
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  /// Crea los 3 técnicos predefinidos si la tabla está vacía (seed inicial).
  Future<void> seedTecnicosPredefinidos() async {
    final existentes = await _db.getAllTecnicos();
    if (existentes.isNotEmpty) return;
    await _db.insertTecnico(drift.TecnicosCompanion(nombre: Value('Juan Pérez'), especialidad: Value('Pantallas')));
    await _db.insertTecnico(drift.TecnicosCompanion(nombre: Value('María Gómez'), especialidad: Value('Placas base')));
    await _db.insertTecnico(drift.TecnicosCompanion(nombre: Value('Carlos Ruiz'), especialidad: Value('Baterías')));
    await cargarTecnicos();
  }

  Future<int> crearTecnico(Tecnico tecnico) async {
    final id = await _db.insertTecnico(tecnico.toCompanion());
    await cargarTecnicos();
    return id;
  }
}

extension _TecnicoCompanion on Tecnico {
  drift.TecnicosCompanion toCompanion() => drift.TecnicosCompanion(
        nombre: Value(nombre),
        especialidad: Value(especialidad),
      );
}

final tecnicoViewModelProvider = StateNotifierProvider<TecnicoViewModel, TecnicoState>((ref) {
  final db = ref.watch(drift.appDatabaseProvider);
  return TecnicoViewModel(db);
});
