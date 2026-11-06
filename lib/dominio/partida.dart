
import 'aparicion.dart';
import 'excepciones.dart';
import 'geo.dart';

// Clase base para los resultados de captura.
sealed class ResultadoCaptura {
  const ResultadoCaptura();
}

// Resultado cuando se captura un personaje.
class Capturado extends ResultadoCaptura {
  final int puntos;

  const Capturado(this.puntos);
}

// Resultado cuando el jugador falla.
class Fallo extends ResultadoCaptura {
  final int intentosRestantes;

  const Fallo(this.intentosRestantes);
}

// Resultado cuando un personaje escapa.
class SeEscapo extends ResultadoCaptura {
  final Coordenada nuevaPosicion;

  const SeEscapo(this.nuevaPosicion);
}

// Clase que administra las reglas del juego.
class Partida {
  // Distancia máxima para capturar.
  static const double radioCaptura = 15;

  // Número máximo de fallos.
  static const int maxFallos = 2;

  // Puntos obtenidos según el intento.
  static const int puntosPrimerIntento = 100;
  static const int puntosSegundoIntento = 50;

  // Personajes que aparecen en el juego.
  final Map<String, Aparicion> _apariciones;

  // Función utilizada para reubicar personajes.
  final Coordenada Function() _reubicar;

  // Personajes capturados.
  final Set<String> _capturados = {};

  // Fallos acumulados por personaje.
  final Map<String, int> _fallos = {};

  // Puntuación del jugador.
  int puntos = 0;

  Partida(
    List<Aparicion> apariciones, {
    required Coordenada Function() reubicar,
  })  : _apariciones = {
          for (final aparicion in apariciones)
            aparicion.personaje.id: aparicion,
        },
        _reubicar = reubicar;

  // Devuelve todos los personajes.
  List<Aparicion> get todas {
    return _apariciones.values.toList();
  }

  // Devuelve los personajes pendientes.
  List<Aparicion> get pendientes {
    return _apariciones.values
        .where(
          (aparicion) =>
              !_capturados.contains(
                aparicion.personaje.id,
              ),
        )
        .toList();
  }

  // Devuelve los IDs de los personajes capturados.
  Set<String> get capturados {
    return Set.unmodifiable(_capturados);
  }

  // Indica si todos fueron capturados.
  bool get terminada {
    return _capturados.length == _apariciones.length;
  }

  // Comprueba si un personaje está capturado.
  bool estaCapturado(String id) {
    return _capturados.contains(id);
  }

  // Restaura personajes capturados anteriormente.
  void restaurar(Iterable<String> ids) {
    _capturados.addAll(
      ids.where(
        _apariciones.containsKey,
      ),
    );
  }

  // Intenta capturar un personaje.
  ResultadoCaptura capturar(
    String id,
    int opcion,
    double distanciaMetros,
  ) {
    // Buscar el personaje.
    final aparicion = _apariciones[id];

    // Verificar que exista.
    if (aparicion == null) {
      throw const PersonajeDesconocidoException();
    }

    // Verificar que no haya sido capturado.
    if (_capturados.contains(id)) {
      throw const YaCapturadoException();
    }

    // Verificar que esté suficientemente cerca.
    if (distanciaMetros > radioCaptura) {
      throw LejosException(distanciaMetros);
    }

    // Consultar los fallos anteriores.
    final fallosPrevios = _fallos[id] ?? 0;

    // Comprobar la respuesta histórica.
    if (aparicion.personaje.pregunta.esCorrecta(
      opcion,
    )) {
      // Calcular los puntos ganados.
      final ganados = fallosPrevios == 0
          ? puntosPrimerIntento
          : puntosSegundoIntento;

      // Sumar puntos.
      puntos += ganados;

      // Registrar el personaje capturado.
      _capturados.add(id);

      return Capturado(ganados);
    }

    // Si la respuesta fue incorrecta,
    // incrementar el número de fallos.
    final fallos = fallosPrevios + 1;

    // Si falló dos veces, el personaje escapa.
    if (fallos >= maxFallos) {
      // Reiniciar los fallos.
      _fallos[id] = 0;

      // Generar una nueva ubicación.
      final nueva = _reubicar();

      // Actualizar la aparición.
      _apariciones[id] = Aparicion(
        aparicion.personaje,
        nueva,
      );

      return SeEscapo(nueva);
    }

    // Guardar los fallos acumulados.
    _fallos[id] = fallos;

    // Indicar los intentos restantes.
    return Fallo(
      maxFallos - fallos,
    );
  }
}
