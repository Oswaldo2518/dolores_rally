
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../dominio/excepciones.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';

// Obtiene posiciones desde el GPS real.
class PosicionGps implements FuentePosicion {
  @override
  Stream<Coordenada> get posiciones async* {
    // 1. Verificar si el GPS está encendido.
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const UbicacionApagadaException();
    }

    // 2. Consultar el permiso de ubicación.
    var permiso = await Geolocator.checkPermission();

    // 3. Solicitar permiso si está denegado.
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    // 4. Verificar si el usuario rechazó el permiso.
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw const PermisoUbicacionException();
    }

    // 5. Escuchar las posiciones del GPS.
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
      ),
    ).map(
      (posicion) => Coordenada(
        posicion.latitude,
        posicion.longitude,
      ),
    );
  }
}

// Obtiene las direcciones de la brújula real.
class BrujulaReal implements FuenteBrujula {
  @override
  Stream<double> get rumbos {
    // Consultar los eventos del magnetómetro.
    final eventos = FlutterCompass.events;

    // Si no existe brújula, generar un error.
    if (eventos == null) {
      return Stream.error(
        const SinBrujulaException(),
      );
    }

    // Escuchar lecturas válidas de la brújula.
    return eventos
        .where(
          (evento) => evento.heading != null,
        )
        .map(
          (evento) => normalizar360(
            evento.heading!,
          ),
        );
  }
}
