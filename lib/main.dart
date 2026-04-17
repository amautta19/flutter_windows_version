import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _version = "Cargando...";
  bool _estaDescargando = false;

  @override
  void initState() {
    super.initState();
    _obtenerVersion();
  }

  void _obtenerVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  // Lógica para descargar el ZIP y disparar el PowerShell
  Future<void> _actualizarPortable() async {
    setState(() => _estaDescargando = true);

    try {
      // 1. URL de tu ZIP en GitHub
      String urlZip = "https://github.com/amautta19/flutter_windows_version/releases/latest/download/update.zip";
      
      // 2. Ruta donde se descargará (en la misma carpeta de la app)
      String pathZip = "${Directory.current.path}/update.zip";

      print("Descargando actualización en: $pathZip");
      await Dio().download(urlZip, pathZip);

      // 3. Ejecutar el script de PowerShell
      // Bypass sirve para saltarse las restricciones de ejecución de la empresa
      await Process.start('powershell', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        'update.ps1'
      ]);

      // 4. Matar la aplicación para que el script pueda reemplazar los archivos
      exit(0);
      
    } catch (e) {
      print("Error actualizando: $e");
      setState(() => _estaDescargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al descargar la actualización")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Portable Update (No Admin)'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Aplicación Windows Portable', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Versión Actual: $_version', style: const TextStyle(fontSize: 16, color: Colors.blue)),
              const SizedBox(height: 30),
              _estaDescargando 
                ? const CircularProgressIndicator() 
                : ElevatedButton.icon(
                    onPressed: _actualizarPortable,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Descargar y Actualizar (Portable)'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}