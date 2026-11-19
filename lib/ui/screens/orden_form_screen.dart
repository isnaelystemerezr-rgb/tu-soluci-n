import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/orden.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

class OrdenFormScreen extends ConsumerStatefulWidget {
  const OrdenFormScreen({super.key});

  @override
  ConsumerState<OrdenFormScreen> createState() => _OrdenFormState();
}

class _OrdenFormState extends ConsumerState<OrdenFormScreen> {
  final _equipoIdCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _equipoIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final equipoId = int.tryParse(_equipoIdCtrl.text);
    if (equipoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID de equipo inválido')));
      return;
    }
    setState(() => _cargando = true);
    try {
      await ref.read(ordenViewModelProvider.notifier).crearOrden(Orden(
        estado: OrdenEstado.recibida,
        equipoId: equipoId,
        manoDeObra: 0,
        fechaCreacion: DateTime.now(),
      ));
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Orden')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Crear una orden de reparación para un equipo existente.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            CustomInputField(
              controller: _equipoIdCtrl,
              label: 'ID del Equipo',
              hint: 'Ej. 1',
              keyboardType: TextInputType.number,
              icon: Icons.device_unknown,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              texto: 'Crear orden',
              cargando: _cargando,
              onPressed: _crear,
              icono: Icons.add_circle,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
