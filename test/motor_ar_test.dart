
import 'package:dolores_rally/dominio/aparicion.dart';
import 'package:dolores_rally/dominio/geo.dart';
import 'package:dolores_rally/dominio/motor_ar.dart';
import 'package:dolores_rally/dominio/personaje.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

// Crea un personaje de prueba en una dirección
// y distancia determinadas.
Aparicion en(
  String id,
  double rumbo,
  double metros,
) {
  return Aparicion(
    Personaje(
      id: id,
      nombre: id,
      emoji: ' ',
      bio: '',
      pregunta: const Pregunta(
        '?',
        ['a', 'b'],
        0,
      ),
    ),
    destino(origen, rumbo, metros),
  );
}

void main() {
  test(
    'un personaje justo adelante aparece en el centro de la pantalla',
    () {
      final visibles = calcularVisibles(
        usuario: origen,
        rumbo: 0,
        apariciones: [
          en('a', 0, 100),
        ],
      );

      expect(
        visibles.single.x,
        closeTo(0.5, 0.01),
      );

      expect(
        visibles.single.distancia,
        closeTo(100, 0.5),
      );
    },
  );

  test(
    'uno a 90° de donde miras no aparece; al girar hacia él, sí',
    () {
      final aparicion = en(
        'a',
        90,
        100,
      );

      // Mirando al norte, el personaje está al este.
      expect(
        calcularVisibles(
          usuario: origen,
          rumbo: 0,
          apariciones: [aparicion],
        ),
        isEmpty,
      );

      // Al girar hacia el este, aparece.
      expect(
        calcularVisibles(
          usuario: origen,
          rumbo: 90,
          apariciones: [aparicion],
        ),
        hasLength(1),
      );
    },
  );

  test(
    'funciona al cruzar el norte (miras a 350° y está a 5°)',
    () {
      final visibles = calcularVisibles(
        usuario: origen,
        rumbo: 350,
        apariciones: [
          en('a', 5, 100),
        ],
      );

      expect(
        visibles,
        hasLength(1),
      );

      expect(
        visibles.single.x,
        greaterThan(0.5),
      );
    },
  );

  test(
    'los lejanos van primero y se ven más pequeños',
    () {
      final visibles = calcularVisibles(
        usuario: origen,
        rumbo: 0,
        apariciones: [
          en('cerca', 0, 40),
          en('lejos', 0, 450),
        ],
      );

      // Primero deben estar los personajes lejanos.
      expect(
        visibles.map(
          (v) => v.aparicion.personaje.id,
        ),
        ['lejos', 'cerca'],
      );

      // Los personajes cercanos se muestran más grandes.
      expect(
        visibles.last.escala,
        greaterThan(visibles.first.escala),
      );
    },
  );

  test(
    'más allá del radio máximo se descartan',
    () {
      final visibles = calcularVisibles(
        usuario: origen,
        rumbo: 0,
        apariciones: [
          en('a', 0, 900),
        ],
        radioMax: 600,
      );

      expect(
        visibles,
        isEmpty,
      );
    },
  );
}
