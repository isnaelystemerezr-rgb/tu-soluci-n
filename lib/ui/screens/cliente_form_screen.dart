import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/cliente.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

class ClienteFormScreen extends ConsumerStatefulWidget {
  const ClienteFormScreen({super.key});

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormState();
}

class _ClienteFormState extends ConsumerState<ClienteFormScreen> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (_nombreCtrl.text.trim().isEmpty || _telefonoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completá nombre y teléfono')));
      return;
    }
    setState(() => _cargando = true);
    try {
      await ref.read(clienteViewModelProvider.notifier).crearCliente(Cliente(
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
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
      appBar: AppBar(title: const Text('Nuevo Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomInputField(controller: _nombreCtrl, label: 'Nombre', icon: Icons.person),
            const SizedBox(height: 12),
            CustomInputField(controller: _telefonoCtrl, label: 'Teléfono', keyboardType: TextInputType.phone, icon: Icons.phone),
            const SizedBox(height: 24),
            PrimaryButton(texto: 'Guardar cliente', cargando: _cargando, onPressed: _crear, icono: Icons.save),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
          ],
        ),
      ),
    );
  }
}
