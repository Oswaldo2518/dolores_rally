
import 'dart:math' as math;

import 'geo.dart';

// Calcula la posición de un objetivo
// dentro de un radar circular.
//
// Devuelve (x, y) entre -1 y 1.
//
// Arriba = hacia donde mira el jugador.
// Abajo = detrás del jugador.
// Derecha e izquierda = posición relativa.
//
// Devuelve null si está fuera del alcance.
(double, double)? puntoEnRadar({
  required Coordenada usuario,
  required double rumbo,
  required Coordenada objetivo,
  double alcance = 500,
}) {
  // Calcular distancia al personaje.
  final distancia = distanciaMetros(
    usuario,
    objetivo,
  );

  // Si está demasiado lejos, no se muestra.
  if (distancia > alcance) {
    return null;
  }

  // Calcular ángulo relativo al jugador.
  final diferencia = diferenciaAngular(
    rumboGrados(usuario, objetivo),
    rumbo,
  );

  // Convertir a radianes.
  final angulo = diferencia * math.pi / 180;

  // Distancia proporcional dentro del radar.
  final fraccion = distancia / alcance;

  // Convertir coordenadas polares
  // a coordenadas cartesianas.
  final x = fraccion * math.sin(angulo);
  final y = -fraccion * math.cos(angulo);

  return (x, y);
}

// Niveles del indicador de proximidad.
enum Temperatura {
  helado,
  frio,
  tibio,
  caliente,
  ardiente,
}

// Determina qué tan cerca está el jugador
// de un personaje.
Temperatura temperaturaPorDistancia(
  double metros,
) {
  if (metros <= 15) {
    return Temperatura.ardiente;
  }

  if (metros <= 50) {
    return Temperatura.caliente;
  }

  if (metros <= 150) {
    return Temperatura.tibio;
  }

  if (metros <= 400) {
    return Temperatura.frio;
  }

  return Temperatura.helado;
}

// Devuelve el texto que verá el jugador
// dependiendo de la distancia.
extension TextoTemperatura on Temperatura {
  String get texto {
    return switch (this) {
      Temperatura.helado => 'Helado',
      Temperatura.frio => 'Frío',
      Temperatura.tibio => 'Tibio',
      Temperatura.caliente => 'Caliente',
      Temperatura.ardiente => '¡Ardiendo! Atrápalo',
    };
  }
}
