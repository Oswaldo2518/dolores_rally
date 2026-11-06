
import 'aparicion.dart';
import 'geo.dart';

// Representa un personaje que puede
// aparecer dentro de la cámara.
class Visible {
  final Aparicion aparicion;

  // Distancia entre el usuario y el personaje.
  final double distancia;

  // Posición horizontal:
  // 0 = izquierda
  // 0.5 = centro
  // 1 = derecha
  final double x;

  // Profundidad:
  // 0 = cerca
  // 1 = lejos
  final double profundidad;

  // Tamaño visual del personaje.
  final double escala;

  const Visible(
    this.aparicion,
    this.distancia,
    this.x,
    this.profundidad,
    this.escala,
  );
}

// Calcula qué personajes deben
// aparecer dentro de la cámara.
List<Visible> calcularVisibles({
  required Coordenada usuario,
  required double rumbo,
  required Iterable<Aparicion> apariciones,
  double campoVision = 60,
  double radioMax = 600,
}) {
  final resultado = <Visible>[];

  // Revisar cada personaje.
  for (final aparicion in apariciones) {
    // 1. Calcular la distancia.
    final distancia = distanciaMetros(
      usuario,
      aparicion.coordenada,
    );

    // 2. Descartar personajes demasiado lejanos.
    if (distancia > radioMax) {
      continue;
    }

    // 3. Calcular hacia dónde está el personaje.
    final rumboPersonaje = rumboGrados(
      usuario,
      aparicion.coordenada,
    );

    // 4. Calcular la diferencia respecto
    // a la dirección de la cámara.
    final diferencia = diferenciaAngular(
      rumboPersonaje,
      rumbo,
    );

    // 5. Calcular la posición horizontal.
    final x = posicionHorizontal(
      diferencia,
      campoVision: campoVision,
    );

    // 6. Si está fuera del campo de visión,
    // no debe aparecer.
    if (x == null) {
      continue;
    }

    // 7. Calcular profundidad.
    final profundidad = (
      distancia / radioMax
    ).clamp(0.0, 1.0).toDouble();

    // 8. Calcular tamaño del personaje.
    final escala = 1.2 - 0.6 * profundidad;

    // 9. Agregar personaje visible.
    resultado.add(
      Visible(
        aparicion,
        distancia,
        x,
        profundidad,
        escala,
      ),
    );
  }

  // 10. Ordenar de lejos hacia cerca.
  resultado.sort(
    (a, b) => b.distancia.compareTo(a.distancia),
  );

  return resultado;
}
