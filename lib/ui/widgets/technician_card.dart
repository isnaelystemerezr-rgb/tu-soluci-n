import 'package:flutter/material.dart';
import '../../models/tecnico.dart';

class TechnicianCard extends StatelessWidget {
  final Tecnico tecnico;
  final int cantidadOrdenes;
  final VoidCallback onTap;

  const TechnicianCard({
    super.key,
    required this.tecnico,
    this.cantidadOrdenes = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(tecnico.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tecnico.especialidad != null) Text('Especialidad: ${tecnico.especialidad}'),
            Text('Órdenes asignadas: $cantidadOrdenes'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
