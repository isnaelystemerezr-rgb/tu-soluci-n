import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/orden.dart';
import '../widgets/technician_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Map<int, String> _nombresTecnicos = {};

  @override
  void initState() {
    super.initState();
    _cargarNombres();
  }

  Future<void> _cargarNombres() async {
    await ref.read(tecnicoViewModelProvider.notifier).cargarTecnicos();
    if (!mounted) return;
    final tecnicos = ref.read(tecnicoViewModelProvider).tecnicos;
    for (final t in tecnicos) {
      _nombresTecnicos[t.id!] = t.nombre;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard – Tu Solution')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(dashboardViewModelProvider.notifier).cargarResumen();
          _cargarNombres();
        },
        child: const Icon(Icons.refresh),
      ),
      body: dashboard.cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen del taller', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _resumenCard(context, 'Abiertas', dashboard.ordenesAbiertas.toString(), Colors.blue, Icons.event_busy),
                      const SizedBox(width: 12),
                      _resumenCard(context, 'Recibidas', dashboard.ordenesRecibidas.toString(), Colors.blueGrey, Icons.inbox),
                      const SizedBox(width: 12),
                      _resumenCard(context, 'En reparación', dashboard.ordenesEnReparacion.toString(), Colors.orange, Icons.build),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _resumenCard(context, 'Lista', dashboard.ordenesLista.toString(), Colors.amber, Icons.check_circle),
                      const SizedBox(width: 12),
                      _resumenCard(context, 'Entregadas', dashboard.ordenesEntregadas.toString(), Colors.green, Icons.done),
                      const SizedBox(width: 12),
                      _resumenCard(context, 'Canceladas', dashboard.ordenesCanceladas.toString(), Colors.red, Icons.cancel),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Carga de trabajo por técnico', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (dashboard.ordenesPorTecnico.isEmpty)
                    const Center(child: Text('Sin órdenes asignadas.'))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: dashboard.ordenesPorTecnico.entries.map((e) {
                        final nombre = _nombresTecnicos[e.key] ?? 'Técnico #${e.key}';
                        return SizedBox(
                          width: 220,
                          child: TechnicianCard(
                            tecnico: Tecnico(id: e.key, nombre: nombre),
                            cantidadOrdenes: e.value,
                            onTap: () => context.push('/ordenes'),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  Text('Órdenes recientes', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  const Center(child: Text('Usá "Órdenes" para ver el listado completo.')),
                ],
              ),
            ),
    );
  }

  Widget _resumenCard(BuildContext context, String titulo, String valor, Color color, IconData icono) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icono, color: color),
                  const Spacer(),
                  Text(valor, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Text(titulo, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
