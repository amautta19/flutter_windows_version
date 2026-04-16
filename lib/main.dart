import 'package:flutter/material.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  // 1. Siempre inicializar antes que nada
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configurar el Auto Updater
  String feedURL = 'https://raw.githubusercontent.com/amautta19/flutter_application_1/master/appcast.xml';
  await autoUpdater.setFeedURL(feedURL);
  await autoUpdater.setScheduledCheckInterval(0); // 0 para que revise siempre al abrir (ideal para pruebas)
  await autoUpdater.checkForUpdates();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _version = "Cargando...";

  @override
  void initState() {
    super.initState();
    _obtenerVersion(); // Obtenemos la versión real del sistema al iniciar
  }

  // Esta función lee el número del pubspec.yaml grabado en el .exe
  void _obtenerVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Windows Versions'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aplicación Windows',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Versión Actual: $_version',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => autoUpdater.checkForUpdates(),
                icon: const Icon(Icons.update),
                label: const Text('Buscar actualizaciones ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}