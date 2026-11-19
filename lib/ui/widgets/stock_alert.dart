import 'package:flutter/material.dart';
import '../../models/repuesto.dart';

class StockAlert extends StatelessWidget {
  final Repuesto repuesto;

  const StockAlert({super.key, required this.repuesto});

  @override
  Widget build(BuildContext context) {
    if (!repuesto.stockBajo) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Stock bajo: ${repuesto.existencias} unidades',
              style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
