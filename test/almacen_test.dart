
import 'package:dolores_rally/dominio/almacen.dart';
import 'package:dolores_rally/datos/almacen_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlmacenMemoria', () {
    test('comienza sin personajes y con cero puntos', () async {
      final almacen = AlmacenMemoria();

      expect(
        await almacen.cargarCapturados(),
        isEmpty,
      );

      expect(
        await almacen.cargarMejorPuntaje(),
        0,
      );
    });

    test('guarda y recupera personajes capturados', () async {
      final almacen = AlmacenMemoria();

      await almacen.guardarCapturados({
        'hidalgo',
        'allende',
      });

      final capturados =
          await almacen.cargarCapturados();

      expect(
        capturados,
        {'hidalgo', 'allende'},
      );
    });

    test('protege la colección de cambios externos', () async {
      final almacen = AlmacenMemoria();

      final originales = <String>{'hidalgo'};

      await almacen.guardarCapturados(originales);

      // Modificar el conjunto original.
      originales.add('allende');

      // Modificar el conjunto recuperado.
      final recuperados =
          await almacen.cargarCapturados();

      recuperados.add('josefa');

      // Los datos guardados no deben cambiar.
      expect(
        await almacen.cargarCapturados(),
        {'hidalgo'},
      );
    });

    test('guarda y recupera el puntaje', () async {
      final almacen = AlmacenMemoria();

      await almacen.guardarMejorPuntaje(250);

      expect(
        await almacen.cargarMejorPuntaje(),
        250,
      );
    });
  });

  group('AlmacenPrefs', () {
    setUp(() {
      // Almacenamiento simulado para cada prueba.
      SharedPreferences.setMockInitialValues({});
    });

    test('comienza vacío y con cero puntos', () async {
      final almacen = AlmacenPrefs();

      expect(
        await almacen.cargarCapturados(),
        isEmpty,
      );

      expect(
        await almacen.cargarMejorPuntaje(),
        0,
      );
    });

    test('guarda y recupera el progreso', () async {
      final almacen = AlmacenPrefs();

      await almacen.guardarCapturados({
        'hidalgo',
        'josefa',
      });

      await almacen.guardarMejorPuntaje(200);

      // Otra instancia debe leer los mismos datos.
      final otroAlmacen = AlmacenPrefs();

      expect(
        await otroAlmacen.cargarCapturados(),
        {'hidalgo', 'josefa'},
      );

      expect(
        await otroAlmacen.cargarMejorPuntaje(),
        200,
      );
    });
  });
}
