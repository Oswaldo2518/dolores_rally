
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// Muestra la cámara trasera del teléfono.
// Si la cámara no funciona, utiliza un fondo
// alternativo para que el juego siga funcionando.
class FondoCamara extends StatefulWidget {
  const FondoCamara({super.key});

  @override
  State<FondoCamara> createState() => _FondoCamaraState();
}

class _FondoCamaraState extends State<FondoCamara> {
  CameraController? _controlador;
  bool _fallo = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    CameraController? nuevo;

    try {
      // Obtener las cámaras disponibles.
      final camaras = await availableCameras();

      // Seleccionar preferentemente la cámara trasera.
      final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );

      nuevo = CameraController(
        trasera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await nuevo.initialize();

      // Comprobar que la pantalla siga abierta.
      if (!mounted) {
        await nuevo.dispose();
        return;
      }

      setState(() {
        _controlador = nuevo;
      });
    } catch (_) {
      await nuevo?.dispose();

      if (mounted) {
        setState(() {
          _fallo = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Liberar los recursos de la cámara.
    _controlador?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controlador;

    if (c != null && c.value.isInitialized) {
      final tamano = c.value.previewSize!;

      // Mostrar la cámara ocupando toda la pantalla.
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: tamano.height,
            height: tamano.width,
            child: CameraPreview(c),
          ),
        ),
      );
    }

    // Fondo alternativo para emuladores sin cámara.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B2A49),
            Color(0xFF4A6FA5),
            Color(0xFFD9A066),
          ],
        ),
      ),
      child: _fallo
          ? const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Sin cámara: usando fondo simulado',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
