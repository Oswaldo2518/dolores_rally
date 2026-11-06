
import 'geo.dart';

// Contrato para obtener posiciones GPS.
//
// Puede ser una fuente real,
// simulada o falsa para pruebas.
abstract class FuentePosicion {
  Stream<Coordenada> get posiciones;
}

// Contrato para obtener rumbos de brújula.
//
// 0 grados significa norte.
// 90 grados significa este.
abstract class FuenteBrujula {
  Stream<double> get rumbos;
}
