
import 'dart:math' as math;

// Representa una coordenada geográfica.
class Coordenada {
  final double lat;
  final double lon;

  const Coordenada(this.lat, this.lon);

  @override
  String toString() =>
      '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
}

// Radio aproximado de la Tierra en metros.
const double _radioTierra = 6371000.0;

// Convierte grados a radianes.
double _rad(double grados) {
  return grados * math.pi / 180;
}

// Convierte radianes a grados.
double _grados(double radianes) {
  return radianes * 180 / math.pi;
}

// Calcula la distancia entre dos coordenadas
// utilizando la fórmula de Haversine.
double distanciaMetros(Coordenada a, Coordenada b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);

  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);

  return 2 *
      _radioTierra *
      math.asin(
        math.sqrt(
          h.clamp(0.0, 1.0).toDouble(),
        ),
      );
}

// Calcula el rumbo desde el punto A hasta el B.
// 0° norte, 90° este, 180° sur, 270° oeste.
double rumboGrados(Coordenada a, Coordenada b) {
  final dLon = _rad(b.lon - a.lon);
  final lat1 = _rad(a.lat);
  final lat2 = _rad(b.lat);

  final y = math.sin(dLon) * math.cos(lat2);

  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) *
          math.cos(lat2) *
          math.cos(dLon);

  return normalizar360(
    _grados(math.atan2(y, x)),
  );
}

// Normaliza cualquier ángulo entre 0° y 360°.
double normalizar360(double grados) {
  return ((grados % 360) + 360) % 360;
}

// Calcula cuánto hay que girar
// desde el rumbo actual hacia un objetivo.
double diferenciaAngular(
  double objetivo,
  double actual,
) {
  var diferencia = normalizar360(
    objetivo - actual,
  );

  if (diferencia > 180) {
    diferencia -= 360;
  }

  return diferencia;
}

// Suaviza los movimientos bruscos de la brújula.
double suavizarAngulo(
  double anterior,
  double nuevo, {
  double alfa = 0.2,
}) {
  return normalizar360(
    anterior +
        alfa * diferenciaAngular(
          nuevo,
          anterior,
        ),
  );
}

// Calcula la posición horizontal de un objeto
// dentro del campo de visión de la cámara.
double? posicionHorizontal(
  double diferencia, {
  double campoVision = 60,
}) {
  if (diferencia.abs() > campoVision / 2) {
    return null;
  }

  return 0.5 + diferencia / campoVision;
}

// Formatea distancias en metros o kilómetros.
String formatearDistancia(double metros) {
  return metros < 1000
      ? '${metros.round()} m'
      : '${(metros / 1000).toStringAsFixed(1)} km';
}

// Obtiene el nombre del punto cardinal.
String nombreCardinal(double grados) {
  const puntos = [
    'N',
    'NE',
    'E',
    'SE',
    'S',
    'SO',
    'O',
    'NO',
  ];

  final indice =
      ((normalizar360(grados) + 22.5) ~/ 45) % 8;

  return puntos[indice];
}

// FUNCIÓN NUEVA: destino.
//
// Calcula las coordenadas a las que llegaría
// una persona después de caminar cierta
// distancia en una dirección determinada.
Coordenada destino(
  Coordenada origen,
  double rumbo,
  double metros,
) {
  // Distancia angular.
  final d = metros / _radioTierra;

  // Rumbo en radianes.
  final br = _rad(rumbo);

  // Coordenadas iniciales en radianes.
  final lat1 = _rad(origen.lat);
  final lon1 = _rad(origen.lon);

  // Calcular nueva latitud.
  final lat2 = math.asin(
    math.sin(lat1) * math.cos(d) +
        math.cos(lat1) *
            math.sin(d) *
            math.cos(br),
  );

  // Calcular nueva longitud.
  final lon2 = lon1 +
      math.atan2(
        math.sin(br) *
            math.sin(d) *
            math.cos(lat1),
        math.cos(d) -
            math.sin(lat1) * math.sin(lat2),
      );

  // Convertir resultados a grados.
  final nuevaLatitud = _grados(lat2);

  final nuevaLongitud =
      ((_grados(lon2) + 540) % 360) - 180;

  return Coordenada(
    nuevaLatitud,
    nuevaLongitud,
  );
}
