
// Contrato para guardar el progreso del jugador.
//
// Solo se almacenan los identificadores de
// los personajes y el puntaje.
//
// No se guardan coordenadas GPS del usuario.
abstract class AlmacenColeccion {
  // Recuperar los personajes capturados.
  Future<Set<String>> cargarCapturados();

  // Guardar los personajes capturados.
  Future<void> guardarCapturados(Set<String> ids);

  // Recuperar el mejor puntaje.
  Future<int> cargarMejorPuntaje();

  // Guardar el mejor puntaje.
  Future<void> guardarMejorPuntaje(int puntos);
}

// Implementación temporal en memoria.
//
// Se utiliza para pruebas automatizadas
// y para el modo DEMO.
class AlmacenMemoria implements AlmacenColeccion {
  Set<String> _ids = {};

  int _mejor = 0;

  @override
  Future<Set<String>> cargarCapturados() async {
    return {..._ids};
  }

  @override
  Future<void> guardarCapturados(
    Set<String> ids,
  ) async {
    _ids = {...ids};
  }

  @override
  Future<int> cargarMejorPuntaje() async {
    return _mejor;
  }

  @override
  Future<void> guardarMejorPuntaje(
    int puntos,
  ) async {
    _mejor = puntos;
  }
}
