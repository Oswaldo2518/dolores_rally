
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../datos/almacen_prefs.dart';
import '../datos/fuentes_reales.dart';
import '../datos/fuentes_simuladas.dart';
import '../dominio/almacen.dart';
import '../dominio/catalogo.dart';
import 'pantalla_coleccion.dart';
import 'pantalla_rally.dart';
import 'rally_viewmodel.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  // Inicia una partida con GPS y brújula reales.
  void _jugarReal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaRally(
          crearVm: () => RallyViewModel(
            posicion: PosicionGps(),
            brujula: BrujulaReal(),
            almacen: AlmacenPrefs(),
            personajes: personajes,
            centro: plazaPrincipal,
            random: math.Random(),
          ),
        ),
      ),
    );
  }

  // Inicia una partida en modo DEMO.
  Future<void> _jugarDemo(BuildContext context) async {
    final posicion = PosicionSimulada(
      plazaPrincipal,
    );

    final brujula = BrujulaSimulada();

    try {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PantallaRally(
            crearVm: () => RallyViewModel(
              posicion: posicion,
              brujula: brujula,

              // El demo no modifica el progreso real.
              almacen: AlmacenMemoria(),

              personajes: personajes,
              centro: plazaPrincipal,
              random: math.Random(),
            ),

            controlesDemo: _ControlesDemo(
              posicion: posicion,
              brujula: brujula,
            ),
          ),
        ),
      );
    } finally {
      // Cerrar los simuladores al salir.
      posicion.cerrar();
      brujula.cerrar();
    }
  }

  // Abre el álbum persistente.
  void _abrirAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaColeccion(
          almacen: AlmacenPrefs(),
          personajes: personajes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rally de la Independencia AR',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Atrapa a los personajes escondidos '
            'en Dolores Hidalgo',
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),

          const SizedBox(height: 8),

          const Text(
            'Usa el radar y el indicador de frío '
            'o caliente para encontrarlos. '
            'Acércate a 15 metros o menos '
            'y responde su pregunta histórica.',
          ),

          const SizedBox(height: 12),

          // Aviso de seguridad física.
          Card(
            color: Colors.amber.shade100,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.deepOrange,
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Mira a tu alrededor, cuida tu '
                      'paso y no cruces la calle '
                      'viendo el teléfono.',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botón para jugar con sensores reales.
          FilledButton.icon(
            onPressed: () => _jugarReal(context),
            icon: const Icon(Icons.explore),
            label: const Text(
              'Jugar en Dolores Hidalgo (GPS real)',
            ),
          ),

          const SizedBox(height: 10),

          // Botón para jugar en el emulador.
          OutlinedButton.icon(
            onPressed: () => _jugarDemo(context),
            icon: const Icon(Icons.school),
            label: const Text(
              'Modo demo (salón de clases)',
            ),
          ),

          const SizedBox(height: 10),

          // Consultar personajes capturados.
          OutlinedButton.icon(
            onPressed: () => _abrirAlbum(context),
            icon: const Icon(
              Icons.collections_bookmark,
            ),
            label: const Text('Mi álbum'),
          ),

          const SizedBox(height: 24),

          Text(
            'Personajes por encontrar',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),

          const SizedBox(height: 8),

          for (final personaje in personajes)
            ListTile(
              leading: const Icon(
                Icons.person_outline,
              ),
              title: Text(personaje.nombre),
            ),
        ],
      ),
    );
  }
}

// Controles para caminar en modo DEMO.
class _ControlesDemo extends StatefulWidget {
  final PosicionSimulada posicion;
  final BrujulaSimulada brujula;

  const _ControlesDemo({
    required this.posicion,
    required this.brujula,
  });

  @override
  State<_ControlesDemo> createState() =>
      _ControlesDemoState();
}

class _ControlesDemoState extends State<_ControlesDemo> {
  double _grados = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Control para girar.
          Row(
            children: [
              const Text(
                'Gira:',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              Expanded(
                child: Slider(
                  min: 0,
                  max: 359,
                  value: _grados,
                  onChanged: (grados) {
                    setState(() {
                      _grados = grados;
                    });

                    widget.brujula.girar(grados);
                  },
                ),
              ),

              Text(
                '${_grados.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Botones de movimiento.
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () {
                  widget.posicion.avanzar(
                    _grados,
                    -10,
                  );
                },
                child: const Text('−10 m'),
              ),

              FilledButton(
                onPressed: () {
                  widget.posicion.avanzar(
                    _grados,
                    10,
                  );
                },
                child: const Text('Avanzar 10 m'),
              ),

              OutlinedButton(
                onPressed: () {
                  widget.posicion.avanzar(
                    _grados,
                    2,
                  );
                },
                child: const Text('+2 m'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
