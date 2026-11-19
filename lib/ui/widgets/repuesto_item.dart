import 'package:flutter/material.dart';
import '../../models/repuesto.dart';
import 'stock_alert.dart';

class RepuestoItem extends StatelessWidget {
  final Repuesto repuesto;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const RepuestoItem({
    super.key,
    required this.repuesto,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(repuesto.codigo.isNotEmpty ? repuesto.codigo[0] : '?')),
        title: Text(repuesto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${repuesto.codigo}   Precio: ${repuesto.precio}'),
            StockAlert(repuesto: repuesto),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEditar),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onEliminar),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
