import 'package:intl/intl.dart';

/// Estados válidos de una orden de reparación.
class OrdenEstado {
  static const String recibida = 'recibida';
  static const String enReparacion = 'en_reparacion';
  static const String lista = 'lista';
  static const String entregada = 'entregada';
  static const String cancelada = 'cancelada';

  static const List<String> todos = [
    recibida,
    enReparacion,
    lista,
    entregada,
    cancelada,
  ];

  static bool esValido(String estado) => todos.contains(estado);

  /// Estados que se consideran "abiertos" (no terminales).
  static bool esAbierto(String estado) =>
      estado == recibida || estado == enReparacion || estado == lista;

  static String etiqueta(String estado) {
    switch (estado) {
      case recibida:
        return 'Recibida';
      case enReparacion:
        return 'En reparación';
      case lista:
        return 'Lista';
      case entregada:
        return 'Entregada';
      case cancelada:
        return 'Cancelada';
      default:
        return estado;
    }
  }
}

/// Modelo de dominio de una Orden de Reparación (Visita).
class Orden {
  final int? id;
  final String estado;
  final int? tecnicoId;
  final int equipoId;
  final int manoDeObra;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  // Cargado por la VM / UI (no persistido directamente en esta fila)
  final List<OrdenRepuesto> repuestosUsados;
  final double? total;

  Orden({
    this.id,
    required this.estado,
    this.tecnicoId,
    required this.equipoId,
    this.manoDeObra = 0,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.repuestosUsados = const [],
    this.total,
  });

  /// Cálculo del total: mano de obra + Σ(cantidad * precio del repuesto).
  int calcularTotalConRepuestos(Map<int, int> preciosPorRepuesto) {
    int totalRepuestos = 0;
    for (final r in repuestosUsados) {
      final precio = preciosPorRepuesto[r.repuestoId] ?? 0;
      totalRepuestos += r.cantidad * precio;
    }
    return manoDeObra + totalRepuestos;
  }

  factory Orden.fromMap(Map<String, dynamic> map) => Orden(
        id: map['id'] as int?,
        estado: map['estado'] as String,
        tecnicoId: map['tecnico_id'] as int?,
        equipoId: map['equipo_id'] as int,
        manoDeObra: map['mano_de_obra'] as int? ?? 0,
        fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
        fechaActualizacion: map['fecha_actualizacion'] != null
            ? DateTime.parse(map['fecha_actualizacion'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'estado': estado,
        'tecnico_id': tecnicoId,
        'equipo_id': equipoId,
        'mano_de_obra': manoDeObra,
        'fecha_creacion': fechaCreacion.toIso8601String(),
        'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
      };

  Orden copyWith({
    int? id,
    String? estado,
    int? tecnicoId,
    int? equipoId,
    int? manoDeObra,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    List<OrdenRepuesto>? repuestosUsados,
    double? total,
  }) {
    return Orden(
      id: id ?? this.id,
      estado: estado ?? this.estado,
      tecnicoId: tecnicoId ?? this.tecnicoId,
      equipoId: equipoId ?? this.equipoId,
      manoDeObra: manoDeObra ?? this.manoDeObra,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      repuestosUsados: repuestosUsados ?? this.repuestosUsados,
      total: total ?? this.total,
    );
  }

  String get fechaFormateada =>
      DateFormat('dd/MM/yyyy HH:mm').format(fechaCreacion);

  @override
  String toString() =>
      'Orden(id: $id, equipo: $equipoId, estado: $estado, tecnico: $tecnicoId, total: $total)';
}
