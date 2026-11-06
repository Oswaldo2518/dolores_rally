
import 'dart:math';

import 'package:dolores_rally/dominio/aparicion.dart';
import 'package:dolores_rally/dominio/catalogo.dart';
import 'package:dolores_rally/dominio/geo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  test('genera una aparición por personaje', () {
    final apariciones = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(1),
    );

    expect(
      apariciones.length,
      personajes.length,
    );

    expect(
      apariciones.map((a) => a.personaje.id).toSet().length,
      personajes.length,
    );
  });

  test('todas quedan entre el radio mínimo y el máximo', () {
    final apariciones = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(7),
      radioMin: 60,
      radioMax: 500,
    );

    for (final aparicion in apariciones) {
      final distancia = distanciaMetros(
        origen,
        aparicion.coordenada,
      );

      expect(
        distancia,
        inInclusiveRange(59.9, 500.1),
      );
    }
  });

  test(
    'con la misma semilla el azar se repite',
    () {
      final a = generarApariciones(
        centro: origen,
        personajes: personajes,
        random: Random(42),
      );

      final b = generarApariciones(
        centro: origen,
        personajes: personajes,
        random: Random(42),
      );

      for (var i = 0; i < a.length; i++) {
        expect(
          a[i].coordenada.lat,
          b[i].coordenada.lat,
        );

        expect(
          a[i].coordenada.lon,
          b[i].coordenada.lon,
        );
      }
    },
  );

  test('con semillas distintas los lugares son distintos', () {
    final a = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(1),
    );

    final b = generarApariciones(
      centro: origen,
      personajes: personajes,
      random: Random(2),
    );

    expect(
      a.first.coordenada.lat,
      isNot(b.first.coordenada.lat),
    );
  });

  test('los puntos se reparten por TODAS las direcciones', () {
    final random = Random(5);

    final rumbos = [
      for (var i = 0; i < 400; i++)
        rumboGrados(
          origen,
          puntoAleatorio(
            origen,
            60,
            500,
            random,
          ),
        ),
    ];

    for (final cuadrante in [0, 90, 180, 270]) {
      expect(
        rumbos.where(
          (rumbo) =>
              rumbo >= cuadrante &&
              rumbo < cuadrante + 90,
        ).length,
        greaterThan(60),
        reason: 'Cuadrante $cuadrante',
      );
    }
  });
}
