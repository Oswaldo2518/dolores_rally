
import 'package:flutter/material.dart';
import '../dominio/radar.dart';
import '../dominio/excepciones.dart';
import '../dominio/geo.dart';
import '../dominio/motor_ar.dart';
import '../dominio/partida.dart';
import '../dominio/personaje.dart';
import 'fondo_camara.dart';
import 'radar_widget.dart';
import 'rally_viewmodel.dart';

class PantallaRally extends StatefulWidget {
  final RallyViewModel Function() crearVm;
  final Widget? controlesDemo;

  const PantallaRally({
    super.key,
    required this.crearVm,
    this.controlesDemo,
  });

  @override
  State<PantallaRally> createState() =>
      _PantallaRallyState();
}

class _PantallaRallyState extends State<PantallaRally> {
  // Crear el ViewModel una sola vez.
  late final RallyViewModel vm = widget.crearVm();

  @override
  void initState() {
    super.initState();

    // Restaurar progreso e iniciar sensores.
    vm.iniciar();
  }

  @override
  void dispose() {
    // Cancelar los sensores al salir.
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // CAPA 1: Cámara.
              const FondoCamara(),

              // CAPA 2: Personajes visibles.
              LayoutBuilder(
                builder: (_, caja) {
                  return Stack(
                    children: [
                      for (final visible in vm.visibles)
                        _personaje(visible, caja),
                    ],
                  );
                },
              ),

              // CAPA 3: Información del jugador.
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _marcador(),
                  ),
                ),
              ),

              // CAPA 4: Radar.
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RadarWidget(
                      puntos: vm.puntosRadar,
                    ),
                  ),
                ),
              ),

              // CAPA 5: Controles del modo DEMO.
              if (widget.controlesDemo != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: widget.controlesDemo!,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Muestra rumbo, personajes, puntos y temperatura.
  Widget _marcador() {
    final temperatura = vm.temperatura?.texto ??
        '¡Los atrapaste a todos!';

    final texto = vm.error ??
        (vm.esperando
            ? 'Buscando GPS y brújula…'
            : vm.lejosDeDolores
                ? 'Estás lejos de Dolores Hidalgo. '
                  'Usa el modo DEMO.'
                : '${nombreCardinal(vm.rumbo!)} '
                  '${vm.rumbo!.round()}°\n'
                  'Capturados: '
                  '${vm.partida.capturados.length}/'
                  '${vm.partida.todas.length}\n'
                  'Puntos: ${vm.partida.puntos}\n'
                  '$temperatura');

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.53,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: vm.error != null
            ? Colors.red.shade800
            : Colors.black54,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  // Muestra un personaje sobre la cámara.
  Widget _personaje(
    Visible visible,
    BoxConstraints caja,
  ) {
    const ancho = 130.0;

    // Determinar si se puede capturar.
    final alAlcance =
        visible.distancia <= Partida.radioCaptura;

    // Posición vertical según la profundidad.
    final top = caja.maxHeight *
        (0.50 - 0.28 * visible.profundidad);

    final emoji = visible.aparicion.personaje.emoji.trim();

    return Positioned(
      left: visible.x * caja.maxWidth - ancho / 2,
      top: top,
      width: ancho,
      child: Transform.scale(
        scale: visible.escala,
        child: GestureDetector(
          onTap: () => _intentar(visible),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Círculo que representa al personaje.
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  border: Border.all(
                    color: alAlcance
                        ? Colors.greenAccent
                        : Colors.white,
                    width: 4,
                  ),
                ),
                child: emoji.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 44,
                        color: Colors.black87,
                      )
                    : Text(
                        emoji,
                        style: const TextStyle(
                          fontSize: 44,
                        ),
                      ),
              ),

              // Distancia o mensaje de captura.
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alAlcance
                      ? '¡Tócame!'
                      : formatearDistancia(
                          visible.distancia,
                        ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Intenta capturar un personaje.
  Future<void> _intentar(Visible visible) async {
    final personaje = visible.aparicion.personaje;

    // Comprobar la distancia.
    if (visible.distancia > Partida.radioCaptura) {
      _aviso(
        LejosException(visible.distancia).toString(),
      );
      return;
    }

    // Mostrar la pregunta histórica.
    final opcion = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoPregunta(
        personaje: personaje,
      ),
    );

    if (!mounted || opcion == null) {
      return;
    }

    try {
      // Evaluar la respuesta.
      final resultado = await vm.capturar(
        personaje.id,
        opcion,
      );

      // Mostrar un mensaje según el resultado.
      final mensaje = switch (resultado) {
        Capturado(:final puntos) =>
          '¡Atrapaste a ${personaje.nombre}! '
          '+$puntos puntos\n${personaje.bio}',

        Fallo(:final intentosRestantes) =>
          'Respuesta incorrecta. '
          'Te queda $intentosRestantes intento.',

        SeEscapo() =>
          '¡${personaje.nombre} se escapó! '
          'Búscalo en otro lugar.',
      };

      _aviso(mensaje);
    } catch (e) {
      _aviso(mensajeSeguro(e));
    }
  }

  // Muestra un aviso en pantalla.
  void _aviso(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Diálogo con la trivia histórica.
class _DialogoPregunta extends StatelessWidget {
  final Personaje personaje;

  const _DialogoPregunta({
    required this.personaje,
  });

  @override
  Widget build(BuildContext context) {
    final pregunta = personaje.pregunta;

    return AlertDialog(
      title: Text(personaje.nombre),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta.texto,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            for (var i = 0;
                i < pregunta.opciones.length;
                i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, i);
                    },
                    child: Text(
                      pregunta.opciones[i],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
