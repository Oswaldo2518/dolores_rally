
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../dominio/almacen.dart';
import '../dominio/aparicion.dart';
import '../dominio/excepciones.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/motor_ar.dart';
import '../dominio/partida.dart';
import '../dominio/personaje.dart';
import '../dominio/radar.dart';

// ViewModel principal del juego.
//
// Se encarga de escuchar el GPS y la brújula,
// actualizar el radar, mostrar personajes
// y gestionar las capturas.
class RallyViewModel extends ChangeNotifier {
  // Distancia máxima antes de considerar
  // que el jugador está lejos de Dolores.
  static const double limiteLejos = 3000;

  // Fuentes de datos.
  final FuentePosicion _posicion;
  final FuenteBrujula _brujula;

  // Almacenamiento del progreso.
  final AlmacenColeccion _almacen;

  // Centro del rally.
  final Coordenada centro;

  // Configuración de realidad aumentada.
  final double campoVision;
  final double radioMax;

  // Partida actual.
  late final Partida partida;

  RallyViewModel({
    required FuentePosicion posicion,
    required FuenteBrujula brujula,
    required AlmacenColeccion almacen,
    required List<Personaje> personajes,
    required this.centro,
    required math.Random random,
    this.campoVision = 60,
    this.radioMax = 600,
  })  : _posicion = posicion,
        _brujula = brujula,
        _almacen = almacen {
    // Generar las apariciones de los personajes.
    partida = Partida(
      generarApariciones(
        centro: centro,
        personajes: personajes,
        random: random,
        radioMax: 500,
      ),

      // Reubicar personajes cuando escapen.
      reubicar: () => puntoAleatorio(
        centro,
        60,
        500,
        random,
      ),
    );
  }

  // Ubicación actual del jugador.
  Coordenada? usuario;

  // Dirección actual de la brújula.
  double? rumbo;

  // Personajes que aparecen en la cámara.
  List<Visible> visibles = [];

  // Mensaje de error.
  String? error;

  // Suscripciones a los sensores.
  StreamSubscription<Coordenada>? _subPos;
  StreamSubscription<double>? _subBru;

  // Indica si todavía falta información.
  bool get esperando {
    return usuario == null || rumbo == null;
  }

  // Detecta si el jugador está a más de
  // tres kilómetros del centro del rally.
  bool get lejosDeDolores {
    return usuario != null &&
        distanciaMetros(
          usuario!,
          centro,
        ) > limiteLejos;
  }

  // Obtiene el personaje pendiente más cercano.
  Aparicion? get masCercano {
    final u = usuario;

    // No calcular si no existe posición
    // o ya se capturaron todos los personajes.
    if (u == null || partida.pendientes.isEmpty) {
      return null;
    }

    final lista = [...partida.pendientes];

    // Ordenar por distancia de menor a mayor.
    lista.sort(
      (a, b) => distanciaMetros(
        u,
        a.coordenada,
      ).compareTo(
        distanciaMetros(
          u,
          b.coordenada,
        ),
      ),
    );

    return lista.first;
  }

  // Distancia al personaje pendiente más cercano.
  double? get distanciaAlMasCercano {
    final cercano = masCercano;

    if (cercano == null || usuario == null) {
      return null;
    }

    return distanciaMetros(
      usuario!,
      cercano.coordenada,
    );
  }

  // Calcula el indicador frío o caliente.
  Temperatura? get temperatura {
    final distancia = distanciaAlMasCercano;

    if (distancia == null) {
      return null;
    }

    return temperaturaPorDistancia(
      distancia,
    );
  }

  // Obtiene las posiciones de los personajes
  // pendientes dentro del radar.
  List<(double, double)> get puntosRadar {
    final u = usuario;
    final r = rumbo;

    // Sin GPS o brújula no podemos dibujar el radar.
    if (u == null || r == null) {
      return const [];
    }

    return [
      for (final aparicion in partida.pendientes)
        if (puntoEnRadar(
              usuario: u,
              rumbo: r,
              objetivo: aparicion.coordenada,
              alcance: radioMax,
            )
            case final punto?)
          punto,
    ];
  }

  // Inicia el juego.
  Future<void> iniciar() async {
    // 1. Recuperar personajes capturados anteriormente.
    partida.restaurar(
      await _almacen.cargarCapturados(),
    );

    // 2. Escuchar posiciones GPS.
    _subPos = _posicion.posiciones.listen(
      (posicion) {
        usuario = posicion;
        _recalcular();
      },
      onError: _alFallar,
    );

    // 3. Escuchar la brújula.
    _subBru = _brujula.rumbos.listen(
      (grados) {
        // La primera lectura se acepta directamente.
        // Las siguientes se suavizan.
        rumbo = rumbo == null
            ? grados
            : suavizarAngulo(
                rumbo!,
                grados,
              );

        _recalcular();
      },
      onError: _alFallar,
    );

    // Avisar a la interfaz.
    notifyListeners();
  }

  // Gestiona errores de los sensores.
  void _alFallar(Object e) {
    error = mensajeSeguro(e);

    notifyListeners();
  }

  // Actualiza los personajes visibles.
  void _recalcular() {
    final u = usuario;
    final r = rumbo;

    if (u != null && r != null) {
      visibles = calcularVisibles(
        usuario: u,
        rumbo: r,
        apariciones: partida.pendientes,
        campoVision: campoVision,
        radioMax: radioMax,
      );
    }

    // Notificar los cambios a la pantalla.
    notifyListeners();
  }

  // Intenta capturar un personaje
  // utilizando su respuesta histórica.
  Future<ResultadoCaptura> capturar(
    String id,
    int opcion,
  ) async {
    final u = usuario;

    // Buscar al personaje seleccionado.
    final aparicion = partida.todas
        .where(
          (a) => a.personaje.id == id,
        )
        .firstOrNull;

    // Calcular la distancia al personaje.
    final distancia = (u == null || aparicion == null)
        ? double.infinity
        : distanciaMetros(
            u,
            aparicion.coordenada,
          );

    // Aplicar las reglas de la partida.
    final resultado = partida.capturar(
      id,
      opcion,
      distancia,
    );

    // Guardar el progreso si fue capturado.
    if (resultado is Capturado) {
      await _almacen.guardarCapturados(
        partida.capturados,
      );

      // Actualizar el récord únicamente
      // si se superó el puntaje anterior.
      final mejorAnterior =
          await _almacen.cargarMejorPuntaje();

      if (partida.puntos > mejorAnterior) {
        await _almacen.guardarMejorPuntaje(
          partida.puntos,
        );
      }
    }

    // Actualizar los personajes visibles.
    _recalcular();

    return resultado;
  }

  // Liberar recursos al cerrar el juego.
  @override
  void dispose() {
    _subPos?.cancel();
    _subBru?.cancel();

    super.dispose();
  }
}
