/// Modelo de dominio de un Técnico.
class Tecnico {
  final int? id;
  final String nombre;
  final String? especialidad;

  Tecnico({
    this.id,
    required this.nombre,
    this.especialidad,
  });

  factory Tecnico.fromMap(Map<String, dynamic> map) => Tecnico(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        especialidad: map['especialidad'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'especialidad': especialidad,
      };

  Tecnico copyWith({int? id, String? nombre, String? especialidad}) {
    return Tecnico(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      especialidad: especialidad ?? this.especialidad,
    );
  }

  @override
  String toString() => 'Tecnico(id: $id, nombre: $nombre)';
}
