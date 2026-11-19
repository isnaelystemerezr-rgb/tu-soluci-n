import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/equipo.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

class EquipoFormScreen extends ConsumerStatefulWidget {
  const EquipoFormScreen({super.key});

  @override
  ConsumerState<EquipoFormScreen> createState() => _EquipoFormState();
}

class _EquipoFormState extends ConsumerState<EquipoFormScreen> {
  final _tipoCtrl = TextEditingController(text: 'celular');
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _serieCtrl = TextEditingController();
  final _fallaCtrl = TextEditingController();
  final _clienteIdCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _tipoCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _serieCtrl.dispose();
    _fallaCtrl.dispose();
    _clienteIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (_marcaCtrl.text.isEmpty || _modeloCtrl.text.isEmpty || _serieCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completá marca, modelo y serie')));
      return;
    }
    setState(() => _cargando = true);
    try {
      await ref.read(equipoViewModelProvider.notifier).crearEquipo(Equipo(
        tipo: _tipoCtrl.text.trim(),
        marca: _marcaCtrl.text.trim(),
        modelo: _modeloCtrl.text.trim(),
        numeroSerie: _serieCtrl.text.trim(),
        fallaReportada: _fallaCtrl.text.trim(),
        clienteId: int.tryParse(_clienteIdCtrl.text.trim()),
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
      appBar: AppBar(title: const Text('Nuevo Equipo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomInputField(controller: _tipoCtrl, label: 'Tipo (celular/tablet/laptop)'),
            const SizedBox(height: 12),
            CustomInputField(controller: _marcaCtrl, label: 'Marca'),
            const SizedBox(height: 12),
            CustomInputField(controller: _modeloCtrl, label: 'Modelo'),
            const SizedBox(height: 12),
            CustomInputField(controller: _serieCtrl, label: 'Número de serie'),
            const SizedBox(height: 12),
            CustomInputField(controller: _fallaCtrl, label: 'Falla reportada', maxLines: 2),
            const SizedBox(height: 12),
            CustomInputField(controller: _clienteIdCtrl, label: 'ID del Cliente (opcional)', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            PrimaryButton(texto: 'Guardar equipo', cargando: _cargando, onPressed: _crear, icono: Icons.save),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
          ],
        ),
      ),
    );
  }
}
