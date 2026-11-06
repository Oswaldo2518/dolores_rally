
import 'dart:math' as math;

import 'geo.dart';
import 'personaje.dart';

// Representa un personaje escondido
// en una coordenada del mapa.
class Aparicion {
  final Personaje personaje;
  final Coordenada coordenada;

  const Aparicion(
    this.personaje,
    this.coordenada,
  );
}

// Genera una coordenada aleatoria
// entre las distancias mínima y máxima
// alrededor del punto central.
Coordenada puntoAleatorio(
  Coordenada centro,
  double min,
  double max,
  math.Random random,
) {
  // Distribución uniforme por área.
  final distancia = math.sqrt(
    min * min +
        random.nextDouble() *
            (max * max - min * min),
  );

  // Generar una dirección aleatoria.
  final rumbo = random.nextDouble() * 360;

  // Obtener las coordenadas de destino.
  return destino(
    centro,
    rumbo,
    distancia,
  );
}

// Genera una aparición aleatoria
// para cada personaje del catálogo.
List<Aparicion> generarApariciones({
  required Coordenada centro,
  required List<Personaje> personajes,
  required math.Random random,
  double radioMin = 60,
  double radioMax = 500,
}) {
  return [
    for (final personaje in personajes)
      Aparicion(
        personaje,
        puntoAleatorio(
          centro,
          radioMin,
          radioMax,
          random,
        ),
      ),
  ];
}
