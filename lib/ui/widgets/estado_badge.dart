import 'package:flutter/material.dart';
import '../../models/orden.dart';

class EstadoBadge extends StatelessWidget {
  final String estado;

  const EstadoBadge({super.key, required this.estado});

  Color _color(String e) {
    switch (e) {
      case OrdenEstado.recibida:
        return Colors.blue;
      case OrdenEstado.enReparacion:
        return Colors.orange;
      case OrdenEstado.lista:
        return Colors.amber;
      case OrdenEstado.entregada:
        return Colors.green;
      case OrdenEstado.cancelada:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color(estado).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color(estado)),
      ),
      child: Text(
        OrdenEstado.etiqueta(estado),
        style: TextStyle(
          color: _color(estado),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
