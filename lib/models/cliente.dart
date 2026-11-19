/// Modelo de dominio de un Cliente.
class Cliente {
  final int? id;
  final String nombre;
  final String telefono;

  Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
  });

  factory Cliente.fromMap(Map<String, dynamic> map) => Cliente(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        telefono: map['telefono'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'telefono': telefono,
      };

  Cliente copyWith({int? id, String? nombre, String? telefono}) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
    );
  }

  @override
  String toString() => 'Cliente(id: $id, nombre: $nombre, telefono: $telefono)';
}
