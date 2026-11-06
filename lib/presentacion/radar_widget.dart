
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Radar circular del juego.
//
// El jugador aparece en el centro.
// Los puntos naranjas son personajes pendientes.
class RadarWidget extends StatelessWidget {
  final List<(double, double)> puntos;
  final double tamano;

  const RadarWidget({
    super.key,
    required this.puntos,
    this.tamano = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _RadarPainter(puntos),
      ),
    );
  }
}

// Dibuja el radar utilizando CustomPainter.
class _RadarPainter extends CustomPainter {
  final List<(double, double)> puntos;

  _RadarPainter(this.puntos);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2;

    // Fondo circular oscuro.
    canvas.drawCircle(
      centro,
      radio,
      Paint()..color = Colors.black54,
    );

    // Líneas verdes del radar.
    final linea = Paint()
      ..color = Colors.greenAccent.withValues(
        alpha: 0.6,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Circunferencia exterior.
    canvas.drawCircle(
      centro,
      radio,
      linea,
    );

    // Circunferencia interior.
    canvas.drawCircle(
      centro,
      radio / 2,
      linea,
    );

    // Línea vertical.
    canvas.drawLine(
      Offset(centro.dx, 0),
      Offset(centro.dx, size.height),
      linea,
    );

    // Línea horizontal.
    canvas.drawLine(
      Offset(0, centro.dy),
      Offset(size.width, centro.dy),
      linea,
    );

    // Triángulo blanco del jugador.
    final jugador = Path()
      ..moveTo(
        centro.dx,
        centro.dy - 7,
      )
      ..lineTo(
        centro.dx - 5,
        centro.dy + 5,
      )
      ..lineTo(
        centro.dx + 5,
        centro.dy + 5,
      )
      ..close();

    canvas.drawPath(
      jugador,
      Paint()..color = Colors.white,
    );

    // Dibujar un punto por cada personaje.
    for (final (x, y) in puntos) {
      final posicion = Offset(
        centro.dx + x * (radio - 6),
        centro.dy + y * (radio - 6),
      );

      canvas.drawCircle(
        posicion,
        5,
        Paint()..color = Colors.orangeAccent,
      );
    }
  }

  // Redibujar cuando cambien los puntos.
  @override
  bool shouldRepaint(covariant _RadarPainter anterior) {
    return !listEquals(anterior.puntos, puntos);
  }
}
