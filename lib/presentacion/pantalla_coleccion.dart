
import 'package:flutter/material.dart';

import '../dominio/almacen.dart';
import '../dominio/personaje.dart';

// Pantalla que muestra los personajes capturados
// y el mejor puntaje del jugador.
class PantallaColeccion extends StatelessWidget {
  final AlmacenColeccion almacen;
  final List<Personaje> personajes;

  const PantallaColeccion({
    super.key,
    required this.almacen,
    required this.personajes,
  });

  // Recuperar el progreso guardado.
  Future<(Set<String>, int)> _cargar() async {
    final ids = await almacen.cargarCapturados();
    final puntos = await almacen.cargarMejorPuntaje();

    return (ids, puntos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi álbum'),
      ),
      body: FutureBuilder<(Set<String>, int)>(
        future: _cargar(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar el álbum.',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final (ids, mejor) = snapshot.data!;

          return Column(
            children: [
              // Contador de personajes y mejor puntaje.
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${ids.length}/${personajes.length} '
                  'personajes · Mejor puntaje: $mejor',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Cuadrícula de personajes.
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(12),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final personaje in personajes)
                      _Carta(
                        personaje: personaje,
                        desbloqueado: ids.contains(
                          personaje.id,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Tarjeta individual del álbum.
class _Carta extends StatelessWidget {
  final Personaje personaje;
  final bool desbloqueado;

  const _Carta({
    required this.personaje,
    required this.desbloqueado,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = personaje.emoji.trim();

    return Card(
      color: desbloqueado
          ? null
          : Colors.grey.shade300,
      child: InkWell(
        // Solo permite abrir personajes capturados.
        onTap: desbloqueado
            ? () {
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(personaje.nombre),
                    content: Text(personaje.bio),
                  ),
                );
              }
            : null,

        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!desbloqueado)
                const Icon(
                  Icons.help_outline,
                  size: 48,
                  color: Colors.grey,
                )
              else if (emoji.isEmpty)
                const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.green,
                )
              else
                Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 48,
                  ),
                ),

              const SizedBox(height: 6),

              Text(
                desbloqueado
                    ? personaje.nombre
                    : 'Por descubrir',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
