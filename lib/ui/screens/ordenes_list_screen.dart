import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/orden.dart';
import '../widgets/order_card.dart';
import '../widgets/estado_badge.dart';

class OrdenesListScreen extends ConsumerStatefulWidget {
  const OrdenesListScreen({super.key});

  @override
  ConsumerState<OrdenesListScreen> createState() => _OrdenesListState();
}

class _OrdenesListState extends ConsumerState<OrdenesListScreen> {
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    ref.read(ordenViewModelProvider.notifier).cargarOrdenes();
  }

  @override
  Widget build(BuildContext context) {
    final ordenes = ref.watch(ordenViewModelProvider).ordenes;

    final filtradas = _filtroEstado == null
        ? ordenes
        : ordenes.where((o) => o.estado == _filtroEstado).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes de Reparación')),
      body: Column(
        children: [
          // Filtro por estado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filtroChip(context, 'Todos', null),
                const SizedBox(width: 8),
                for (final e in OrdenEstado.todos)
                  _filtroChip(context, OrdenEstado.etiqueta(e), e),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtradas.isEmpty
                ? const Center(child: Text('No hay órdenes con este filtro.'))
                : ListView.builder(
                    itemCount: filtradas.length,
                    itemBuilder: (_, i) {
                      final o = filtradas[i];
                      return OrderCard(
                        orden: o,
                        equipoLabel: 'Equipo #${o.equipoId}',
                        tecnicoLabel: o.tecnicoId != null ? 'Técnico #${o.tecnicoId}' : 'Sin asignar',
                        onTap: () => context.push('/ordenes/${o.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ordenes/nueva'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filtroChip(BuildContext context, String label, String? estado) {
    final seleccionado = _filtroEstado == estado;
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => setState(() => _filtroEstado = seleccionado ? null : estado),
    );
  }
}
