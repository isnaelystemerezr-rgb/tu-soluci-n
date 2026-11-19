import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

class HistorialScreen extends ConsumerStatefulWidget {
  const HistorialScreen({super.key});

  @override
  ConsumerState<HistorialScreen> createState() => _HistorialState();
}

class _HistorialState extends ConsumerState<HistorialState> {
  final _buscarCtrl = TextEditingController();
  String _campo = 'serie'; // 'serie' o 'telefono'
  List<Map<String, dynamic>> _resultados = [];
  bool _cargando = false;

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final q = _buscarCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _cargando = true);
    try {
      if (_campo == 'serie') {
        final equipos = await ref.read(equipoViewModelProvider.notifier).cargarEquiposPorCliente(0);
        // buscar equipos por serie usa la DB directamente
        final db = ref.read(appDatabaseProvider);
        final lista = await db.buscarEquiposPorSerie(q);
        _resultados = lista.map((e) {
          return {
            'tipo': 'equipo',
            'id': e.id,
            'marca': e.marca,
            'modelo': e.modelo,
            'serie': e.numeroSerie,
          };
        }).toList();
      } else {
        // buscar por teléfono: cargar clientes y filtrar
        final db = ref.read(appDatabaseProvider);
        final clientes = await db.getAllClientes();
        final cliente = clientes.firstWhere(
          (c) => c.telefono.contains(q),
          orElse: () => throw Exception('No encontrado'),
        );
        final ordenes = await db.ordenesPorCliente(cliente.id!);
        _resultados = ordenes.map((o) {
          return {
            'tipo': 'orden',
            'id': o.id,
            'estado': o.estado,
            'cliente': cliente.nombre,
            'telefono': cliente.telefono,
          };
        }).toList();
      }
    } catch (e) {
      _resultados = [];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se encontró: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Reparaciones')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _campo,
                    items: const [
                      DropdownMenuItem(value: 'serie', child: Text('Por número de serie')),
                      DropdownMenuItem(value: 'telefono', child: Text('Por teléfono del cliente')),
                    ],
                    onChanged: (v) => setState(() => _campo = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomInputField(controller: _buscarCtrl, label: 'Buscar'),
                ),
                const SizedBox(width: 12),
                PrimaryButton(texto: 'Buscar', onPressed: _buscar, cargando: _cargando),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _resultados.isEmpty
                  ? const Center(child: Text('Sin resultados.'))
                  : ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (_, i) {
                        final r = _resultados[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(r['tipo'] == 'equipo'
                                ? '${r['marca']} ${r['modelo']}'
                                : 'Orden #${r['id']} – ${r['cliente']}'),
                            subtitle: Text(r['tipo'] == 'equipo'
                                ? 'Serie: ${r['serie']}'
                                : 'Estado: ${r['estado']}  |  Tel: ${r['telefono']}'),
                            trailing: r['tipo'] == 'orden'
                                ? const Icon(Icons.chevron_right)
                                : null,
                            onTap: r['tipo'] == 'orden'
                                ? () => context.push('/ordenes/${r['id']}')
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
