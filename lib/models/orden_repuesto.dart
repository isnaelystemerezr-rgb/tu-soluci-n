/// Modelo de dominio de la tabla intermedia OrdenRepuesto.
class OrdenRepuesto {
  final int? id;
  final int ordenId;
  final int repuestoId;
  final int cantidad;

  OrdenRepuesto({
    this.id,
    required this.ordenId,
    required this.repuestoId,
    this.cantidad = 1,
  });

  factory OrdenRepuesto.fromMap(Map<String, dynamic> map) => OrdenRepuesto(
        id: map['id'] as int?,
        ordenId: map['orden_id'] as int,
        repuestoId: map['repuesto_id'] as int,
        cantidad: map['cantidad'] as int? ?? 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'orden_id': ordenId,
        'repuesto_id': repuestoId,
        'cantidad': cantidad,
      };

  int subtotal(int precioUnitario) => cantidad * precioUnitario;

  @override
  String toString() => 'OrdenRepuesto(orden: $ordenId, repuesto: $repuestoId, x$cantidad)';
}
