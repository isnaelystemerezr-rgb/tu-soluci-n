import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/orden.dart';
import '../widgets/estado_badge.dart';
import '../widgets/stock_alert.dart';
import '../widgets/primary_button.dart';

class OrdenDetailScreen extends ConsumerStatefulWidget {
  final int ordenId;
  const OrdenDetailScreen({super.key, required this.ordenId});

  @override
  ConsumerState<OrdenDetailScreen> createState() => _OrdenDetailState();
}

class _OrdenDetailState extends ConsumerState<OrdenDetailScreen> {
  final _manoDeObraCtrl = TextEditingController();
  String _nuevoEstado = OrdenEstado.recibida;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _manoDeObraCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    await ref.read(ordenViewModelProvider.notifier).cargarDetalle(widget.ordenId);
    final d = ref.read(ordenViewModelProvider).detalleSeleccionado;
    if (d != null) {
      _manoDeObraCtrl.text = d.orden.manoDeObra.toString();
      _nuevoEstado = d.orden.estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(ordenViewModelProvider);
    final detalle = vm.detalleSeleccionado;

    return Scaffold(
      appBar: AppBar(
        title: detalle == null ? const Text('Cargando…') : Text('Orden #${detalle.orden.id}'),
      ),
      body: detalle == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Estado
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _nuevoEstado,
                                  items: OrdenEstado.todos.map((e) {
                                    return DropdownMenuItem(
                                      value: e,
                                      child: Text(OrdenEstado.etiqueta(e)),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setState(() => _nuevoEstado = v!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                detalle.tecnico != null
                                    ? 'Técnico: ${detalle.tecnico!.nombre}'
                                    : 'Técnico: sin asignar',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Equipo
                  if (detalle.equipo != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Equipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('${detalle.equipo!.marca} ${detalle.equipo!.modelo}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('Tipo: ${detalle.equipo!.tipo}', style: const TextStyle(color: Colors.grey)),
                            Text('Serie: ${detalle.equipo!.numeroSerie}', style: const TextStyle(color: Colors.grey)),
                            Text('Falla reportada: ${detalle.equipo!.fallaReportada}'),
                            if (detalle.equipo!.clienteId != null)
                              Text('Cliente ID: ${detalle.equipo!.clienteId}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Mano de obra
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mano de obra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _manoDeObraCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Costo',
                              border: OutlineInputBorder(),
                              prefixText: '\$',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  texto: 'Guardar mano de obra',
                                  onPressed: () async {
                                    final monto = int.tryParse(_manoDeObraCtrl.text) ?? 0;
                                    await ref.read(ordenViewModelProvider.notifier).agregarManoDeObra(detalle.orden.id!, monto);
                                    _cargar();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => ref.read(ordenViewModelProvider.notifier).cambiarEstado(detalle.orden.id!, _nuevoEstado),
                                  child: const Text('Cambiar estado'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Repuestos usados
                  Text('Repuestos usados', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (detalle.repuestosConDetalle.isEmpty)
                    const Text('Sin repuestos registrados.')
                  else
                    Column(
                      children: detalle.repuestosConDetalle.map((r) {
                        return ListTile(
                          leading: const Icon(Icons.build),
                          title: Text('${r['nombre']} (${r['codigo']})'),
                          subtitle: Text('x${r['cantidad']}  subtotal: ${r['subtotal']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => ref.read(ordenViewModelProvider.notifier).quitarRepuestoDeOrden(
                                  r['ordenRepuestoId'] as int,
                                  r['repuestoId'] as int,
                                  r['cantidad'] as int,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),

                  // Agregar repuesto desde inventario
                  _agregarRepuestoForm(detalle),

                  const SizedBox(height: 24),
                  // Total
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${detalle.total}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _agregarRepuestoForm(detalle) {
    final repuestoCtrl = TextEditingController();
    final cantidadCtrl = TextEditingController(text: '1');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agregar repuesto del inventario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: repuestoCtrl,
              decoration: const InputDecoration(
                labelText: 'Código o nombre del repuesto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                texto: 'Buscar y agregar',
                onPressed: () async {
                  final query = repuestoCtrl.text.trim();
                  final cantidad = int.tryParse(cantidadCtrl.text) ?? 1;
                  await ref.read(repuestoViewModelProvider.notifier).cargarRepuestos();
                  final all = ref.read(repuestoViewModelProvider).repuestos;
                  final encontrado = all.where(
                    (r) => r.codigo.toLowerCase().contains(query.toLowerCase()) ||
                        r.nombre.toLowerCase().contains(query.toLowerCase()),
                  ).toList();
                  if (encontrado.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró el repuesto')));
                    return;
                  }
                  final r = encontrado.first;
                  await ref.read(ordenViewModelProvider.notifier).agregarRepuestoAOrden(detalle.orden.id!, r.id!, cantidad);
                  _cargar();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
