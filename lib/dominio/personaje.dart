
class Pregunta {
  final String texto;
  final List<String> opciones;
  final int correcta;

  const Pregunta(
    this.texto,
    this.opciones,
    this.correcta,
  );

  // Comprueba si la opción seleccionada es correcta.
  bool esCorrecta(int opcion) {
    return opcion == correcta;
  }
}

class Personaje {
  final String id;
  final String nombre;
  final String emoji;
  final String bio;
  final Pregunta pregunta;

  const Personaje({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.bio,
    required this.pregunta,
  });
}
