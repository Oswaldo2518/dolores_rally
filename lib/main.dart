
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'presentacion/pantalla_inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Utilizar el teléfono en orientación vertical.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rally de la Independencia AR',

      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),

      home: const PantallaInicio(),
    ),
  );
}
