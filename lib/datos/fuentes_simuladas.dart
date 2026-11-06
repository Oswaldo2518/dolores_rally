
import 'dart:async';

import '../dominio/fuentes.dart';
import '../dominio/geo.dart';

// Simula el GPS de un jugador.
//
// Permite avanzar o retroceder
// sin utilizar sensores reales.
class PosicionSimulada implements FuentePosicion {
  // Posición actual del jugador.
  Coordenada _actual;

  // Controlador de posiciones simuladas.
  final _controlador =
      StreamController<Coordenada>.broadcast();

  PosicionSimulada(this._actual);

  @override
  Stream<Coordenada> get posiciones async* {
    // Entregar la posición inicial.
    yield _actual;

    // Después escuchar nuevos movimientos.
    yield* _controlador.stream;
  }

  // Mueve al jugador en una dirección.
  //
  // rumbo: dirección del movimiento.
  // metros: distancia que debe avanzar.
  //
  // Si metros es negativo, retrocede.
  void avanzar(
    double rumbo,
    double metros,
  ) {
    if (metros >= 0) {
      // Avanzar en la dirección indicada.
      _actual = destino(
        _actual,
        rumbo,
        metros,
      );
    } else {
      // Retroceder en dirección contraria.
      _actual = destino(
        _actual,
        rumbo + 180,
        -metros,
      );
    }

    // Notificar la nueva ubicación.
    _controlador.add(_actual);
  }

  // Cerrar el controlador.
  void cerrar() {
    _controlador.close();
  }
}

// Simula la dirección de una brújula.
//
// Más adelante se controlará con
// un deslizador en pantalla.
class BrujulaSimulada implements FuenteBrujula {
  final _controlador =
      StreamController<double>.broadcast();

  // Rumbo inicial: norte.
  double _ultimo = 0;

  @override
  Stream<double> get rumbos async* {
    // Entregar el rumbo inicial.
    yield _ultimo;

    // Escuchar los cambios de dirección.
    yield* _controlador.stream;
  }

  // Cambiar la dirección de la brújula.
  void girar(double grados) {
    _ultimo = grados;

    // Notificar el nuevo rumbo.
    _controlador.add(grados);
  }

  // Liberar los recursos.
  void cerrar() {
    _controlador.close();
  }
}
