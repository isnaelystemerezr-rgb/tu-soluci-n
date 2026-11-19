/// Modelo de dominio de un Repuesto (inventario).
class Repuesto {
  final int? id;
  final String nombre;
  final String codigo;
  final int precio; // precio unitario
  final int existencias;

  Repuesto({
    this.id,
    required this.nombre,
    required this.codigo,
    required this.precio,
    this.existencias = 0,
  });

  bool get stockBajo => existencias < 3;

  factory Repuesto.fromMap(Map<String, dynamic> map) => Repuesto(
        id: map['id'] as int?,
        nombre: map['nombre'] as String,
        codigo: map['codigo'] as String,
        precio: map['precio'] as int,
        existencias: map['existencias'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'codigo': codigo,
        'precio': precio,
        'existencias': existencias,
      };

  Repuesto copyWith({
    int? id,
    String? nombre,
    String? codigo,
    int? precio,
    int? existencias,
  }) {
    return Repuesto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      precio: precio ?? this.precio,
      existencias: existencias ?? this.existencias,
    );
  }

  @override
  String toString() => 'Repuesto(id: $id, $nombre ($codigo), stock: $existencias)';
}
