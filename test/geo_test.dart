
import 'package:dolores_rally/dominio/geo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  group('destino: caminar N metros hacia un rumbo', () {
    test('100 m al norte queda a 100 m con rumbo 0°', () {
      final d = destino(origen, 0, 100);

      expect(
        distanciaMetros(origen, d),
        closeTo(100, 0.01),
      );

      // Comparar ángulos considerando el cruce 360° -> 0°.
      expect(
        diferenciaAngular(
          rumboGrados(origen, d),
          0,
        ).abs(),
        lessThan(0.01),
      );
    });

    test(
      'ida y vuelta: distancia y rumbo se conservan en cualquier dirección',
      () {
        for (final rumbo in <double>[
          0,
          45,
          90,
          135,
          180,
          225,
          270,
          315,
          359,
        ]) {
          final d = destino(origen, rumbo, 250);

          expect(
            distanciaMetros(origen, d),
            closeTo(250, 0.05),
            reason: 'Distancia con rumbo $rumbo',
          );

          // Comparar contra el rumbo de esta iteración,
          // no contra 0.
          expect(
            diferenciaAngular(
              rumboGrados(origen, d),
              rumbo,
            ).abs(),
            lessThan(0.05),
            reason: 'Rumbo $rumbo',
          );
        }
      },
    );

    test('0 metros te deja en el mismo punto', () {
      final d = destino(origen, 123, 0);

      expect(
        distanciaMetros(origen, d),
        closeTo(0, 1e-6),
      );
    });
  });

  group('recordatorio de la guía anterior', () {
    test('un grado de latitud mide unos 111.2 km', () {
      expect(
        distanciaMetros(
          const Coordenada(0, 0),
          const Coordenada(1, 0),
        ),
        closeTo(111195, 5),
      );
    });

    test(
      'diferenciaAngular cruza el norte por el camino corto',
      () {
        expect(diferenciaAngular(10, 350), 20);
        expect(diferenciaAngular(350, 10), -20);
      },
    );

    test(
      'suavizarAngulo no se rompe en el salto 350° a 10°',
      () {
        expect(
          suavizarAngulo(
            350,
            10,
            alfa: 0.5,
          ),
          closeTo(0, 1e-9),
        );
      },
    );

    test(
      'posicionHorizontal: centro, borde y fuera de campo',
      () {
        expect(posicionHorizontal(0), 0.5);
        expect(posicionHorizontal(30), closeTo(1.0, 1e-9));
        expect(posicionHorizontal(31), isNull);
      },
    );
  });
}
