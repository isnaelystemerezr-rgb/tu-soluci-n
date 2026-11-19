/// Modelo de dominio de un Equipo.
class Equipo {
  final int? id;
  final String tipo; // celular, tablet, laptop
  final String marca;
  final String modelo;
  final String numeroSerie;
  final String fallaReportada;
  final int? clienteId;

  Equipo({
    this.id,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.fallaReportada,
    this.clienteId,
  });

  factory Equipo.fromMap(Map<String, dynamic> map) => Equipo(
        id: map['id'] as int?,
        tipo: map['tipo'] as String,
        marca: map['marca'] as String,
        modelo: map['modelo'] as String,
        numeroSerie: map['numero_serie'] as String,
        fallaReportada: map['falla_reportada'] as String,
        clienteId: map['cliente_id'] as int?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'tipo': tipo,
        'marca': marca,
        'modelo': modelo,
        'numero_serie': numeroSerie,
        'falla_reportada': fallaReportada,
        'cliente_id': clienteId,
      };

  Equipo copyWith({
    int? id,
    String? tipo,
    String? marca,
    String? modelo,
    String? numeroSerie,
    String? fallaReportada,
    int? clienteId,
  }) {
    return Equipo(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      fallaReportada: fallaReportada ?? this.fallaReportada,
      clienteId: clienteId ?? this.clienteId,
    );
  }

  @override
  String toString() => 'Equipo(id: $id, $marca $modelo, serie: $numeroSerie)';
}
