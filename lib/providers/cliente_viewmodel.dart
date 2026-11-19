import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart' as drift;
import '../models/cliente.dart';

/// Estado del ViewModel de Clientes.
class ClienteState {
  final List<Cliente> clientes;
  final bool cargando;
  final String? error;

  ClienteState({
    required this.clientes,
    this.cargando = false,
    this.error,
  });

  ClienteState copyWith({
    List<Cliente>? clientes,
    bool? cargando,
    String? error,
  }) {
    return ClienteState(
      clientes: clientes ?? this.clientes,
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
    );
  }
}

/// ViewModel de Clientes (MVVM). Gestiona la lista de clientes y su persistencia.
class ClienteViewModel extends StateNotifier<ClienteState> {
  final drift.AppDatabase _db;

  ClienteViewModel(this._db) : super(const ClienteState(clientes: []));

  Future<void> cargarClientes() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final rows = await _db.getAllClientes();
      state = state.copyWith(
        clientes: rows.map((r) => Cliente(id: r.id, nombre: r.nombre, telefono: r.telefono)).toList(),
        cargando: false,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<int> crearCliente(Cliente cliente) async {
    final id = await _db.insertCliente(cliente.toCompanion());
    await cargarClientes();
    return id;
  }

  Future<int> actualizarCliente(Cliente cliente) async {
    if (cliente.id == null) return 0;
    await _db.updateCliente(cliente.id!, cliente.toCompanion());
    await cargarClientes();
    return cliente.id!;
  }

  Future<void> eliminarCliente(int id) async {
    await _db.deleteCliente(id);
    await cargarClientes();
  }
}

/// Compañero de escritura para Drift (mapeo desde el modelo de dominio).
extension _ClienteCompanion on Cliente {
  drift.ClientesCompanion toCompanion() => drift.ClientesCompanion(
        nombre: Value(nombre),
        telefono: Value(telefono),
      );
}

/// Provider del ViewModel de Clientes.
final clienteViewModelProvider = StateNotifierProvider<ClienteViewModel, ClienteState>((ref) {
  final db = ref.watch(drift.appDatabaseProvider);
  return ClienteViewModel(db);
});
