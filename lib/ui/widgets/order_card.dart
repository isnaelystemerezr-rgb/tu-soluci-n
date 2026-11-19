import 'package:flutter/material.dart';
import '../../models/orden.dart';
import 'estado_badge.dart';

class OrderCard extends StatelessWidget {
  final Orden orden;
  final String? equipoLabel;
  final String? tecnicoLabel;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.orden,
    this.equipoLabel,
    this.tecnicoLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.device_unknown, size: 32),
        title: Text('Orden #${orden.id ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (equipoLabel != null) Text(equipoLabel!),
            if (tecnicoLabel != null) Text('Técnico: $tecnicoLabel'),
            Text(orden.fechaFormateada, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: EstadoBadge(estado: orden.estado),
        onTap: onTap,
      ),
    );
  }
}
