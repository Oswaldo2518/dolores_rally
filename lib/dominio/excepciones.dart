
abstract class ErrorDeApp implements Exception {
  const ErrorDeApp();
}

// Error cuando se niega el permiso de ubicación.
class PermisoUbicacionException extends ErrorDeApp {
  const PermisoUbicacionException();

  @override
  String toString() =>
      'Necesito el permiso de ubicación para jugar. '
      'Actívalo en Ajustes.';
}

// Error cuando el GPS está desactivado.
class UbicacionApagadaException extends ErrorDeApp {
  const UbicacionApagadaException();

  @override
  String toString() =>
      'El GPS está apagado. Actívalo para jugar.';
}

// Error cuando no hay brújula.
class SinBrujulaException extends ErrorDeApp {
  const SinBrujulaException();

  @override
  String toString() =>
      'Este dispositivo no tiene brújula. '
      'Usa el modo demo.';
}

// Error cuando el personaje está demasiado lejos.
class LejosException extends ErrorDeApp {
  final double metros;

  const LejosException(this.metros);

  @override
  String toString() =>
      'Estás a ${metros.round()} m. '
      'Acércate a menos de 15 m para atraparlo.';
}

// Error cuando el personaje ya fue capturado.
class YaCapturadoException extends ErrorDeApp {
  const YaCapturadoException();

  @override
  String toString() =>
      'Ya atrapaste a este personaje.';
}

// Error cuando el personaje no existe.
class PersonajeDesconocidoException extends ErrorDeApp {
  const PersonajeDesconocidoException();

  @override
  String toString() =>
      'Ese personaje no existe en el juego.';
}

// Convierte los errores en mensajes seguros.
String mensajeSeguro(Object error) {
  return error is ErrorDeApp
      ? error.toString()
      : 'Ocurrió un error inesperado. Intenta de nuevo.';
}
