import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  final IconData? icono;

  const PrimaryButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icono != null ? Icon(icono) : const SizedBox.shrink(),
      label: Text(texto),
      onPressed: cargando ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: cargando
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(texto, style: const TextStyle(fontSize: 16)),
    );
  }
}
