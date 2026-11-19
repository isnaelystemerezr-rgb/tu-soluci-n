import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/repuesto.dart';
import '../widgets/repuesto_item.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

class InventarioScreen extends ConsumerStatefulWidget {
  const InventarioScreen({super.key});

  @override
  ConsumerState<InventarioScreen> createState() => _InventarioState();
}

class _InventarioState extends ConsumerState<InventarioScreen> {
  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    ref.read(repuestoViewModelProvider.notifier).cargarRepuestos();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    setState(() => _cargando = true);
    try {
      await ref.read(repuestoViewModelProvider.notifier).crearRepuesto(Repuesto(
        nombre: _nombreCtrl.text.trim(),
        codigo: _codigoCtrl.text.trim(),
        precio: int.tryParse(_precioCtrl.text) ?? 0,
        existencias: int.tryParse(_stockCtrl.text) ?? 0,
      ));
      _nombreCtrl.clear();
      _codigoCtrl.clear();
      _precioCtrl.clear();
      _stockCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repuestoViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Repuestos')),
      body: Column(
        children: [
          // Formulario CRUD
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Agregar / editar repuesto', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: CustomInputField(controller: _nombreCtrl, label: 'Nombre')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: CustomInputField(controller: _codigoCtrl, label: 'Código')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: CustomInputField(controller: _precioCtrl, label: 'Precio', keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomInputField(controller: _stockCtrl, label: 'Existencias', keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(texto: 'Guardar repuesto', cargando: _cargando, onPressed: _crear, icono: Icons.inventory),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Lista
          Expanded(
            child: state.cargando
                ? const Center(child: CircularProgressIndicator())
                : state.repuestos.isEmpty
                ? const Center(child: Text('No hay repuestos en el inventario.'))
                : ListView.builder(
                    itemCount: state.repuestos.length,
                    itemBuilder: (_, i) {
                      final r = state.repuestos[i];
                      return RepuestoItem(
                        repuesto: r,
                        onTap: () {},
                        onEditar: () => _cargarParaEditar(r),
                        onEliminar: () async {
                          await ref.read(repuestoViewModelProvider.notifier).eliminarRepuesto(r.id!);
                        },
                      );
                    },
                  ),
          ),
          if (state.stockBajo.isNotEmpty)
            Container(
              color: Colors.orange.shade50,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️ Stock bajo (< 3)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 6),
                  ...state.stockBajo.map((r) => Text('• ${r.nombre} (${r.codigo}): ${r.existencias} unidades')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _cargarParaEditar(Repuesto r) {
    _nombreCtrl.text = r.nombre;
    _codigoCtrl.text = r.codigo;
    _precioCtrl.text = r.precio.toString();
    _stockCtrl.text = r.existencias.toString();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar repuesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInputField(controller: _nombreCtrl, label: 'Nombre'),
            const SizedBox(height: 8),
            CustomInputField(controller: _codigoCtrl, label: 'Código'),
            const SizedBox(height: 8),
            CustomInputField(controller: _precioCtrl, label: 'Precio', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CustomInputField(controller: _stockCtrl, label: 'Existencias', keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(texto: 'Guardar', onPressed: () async {
              await ref.read(repuestoViewModelProvider.notifier).actualizarRepuesto(Repuesto(
                id: r.id,
                nombre: _nombreCtrl.text.trim(),
                codigo: _codigoCtrl.text.trim(),
                precio: int.tryParse(_precioCtrl.text) ?? 0,
                existencias: int.tryParse(_stockCtrl.text) ?? 0,
              ));
              context.pop();
            }),
          ),
        ],
      ),
    );
  }
}
