
import 'package:shared_preferences/shared_preferences.dart';

import '../dominio/almacen.dart';

// Almacena el progreso del jugador
// localmente en el teléfono.
//
// No requiere internet ni servidores.
class AlmacenPrefs implements AlmacenColeccion {
  // Claves utilizadas para almacenar los datos.
  static const _claveIds = 'capturados';

  static const _claveMejor = 'mejor_puntaje';

  // Recuperar los personajes capturados.
  @override
  Future<Set<String>> cargarCapturados() async {
    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_claveIds) ??
        const <String>[];

    return ids.toSet();
  }

  // Guardar los personajes capturados.
  @override
  Future<void> guardarCapturados(
    Set<String> ids,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _claveIds,
      ids.toList(),
    );
  }

  // Recuperar el mejor puntaje.
  @override
  Future<int> cargarMejorPuntaje() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_claveMejor) ?? 0;
  }

  // Guardar el mejor puntaje.
  @override
  Future<void> guardarMejorPuntaje(
    int puntos,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _claveMejor,
      puntos,
    );
  }
}
