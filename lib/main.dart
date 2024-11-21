
import 'package:flutter/material.dart';  // Importa la librería de Flutter para la interfaz de usuario
import 'package:flutter_application_acelerometro_modooscuro_funcionalidades/viwes/SensorScreen.dart';  // Importa la pantalla del sensor
import 'package:camera/camera.dart';  // Importa la librería para el uso de la cámara
import 'package:permission_handler/permission_handler.dart';  // Importa la librería para manejar permisos
import 'package:provider/provider.dart';  // Importa la librería para la gestión del estado
import 'package:flutter_background/flutter_background.dart';  // Importa la librería para la ejecución en segundo plano

List<CameraDescription> cameras = [];  // Lista para almacenar las descripciones de las cámaras disponibles

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Asegura que los widgets estén inicializados
  cameras = await availableCameras();  // Obtiene las cámaras disponibles

  // Solicita los permisos necesarios
  await _requestPermissions();

  // Inicia los servicios en segundo plano para el acelerómetro y la cámara
  await startBackgroundServices();

  runApp(MyApp());  // Ejecuta la aplicación principal
}

// Función para iniciar los servicios en segundo plano
Future<void> startBackgroundServices() async {
  // Configuración para el servicio del acelerómetro en segundo plano
  final androidConfigAccelerometer = FlutterBackgroundAndroidConfig(
    notificationTitle: "Acelerómetro en segundo plano",
    notificationText: "El acelerómetro está activo en segundo plano",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon:
        AndroidResource(name: 'background_icon', defType: 'drawable'),
  );
  bool accelerometerInitialized = await FlutterBackground.initialize(
      androidConfig: androidConfigAccelerometer);
  if (accelerometerInitialized) {
    await FlutterBackground.enableBackgroundExecution();
  }

  // Configuración para el servicio de la cámara en segundo plano
  final androidConfigCamera = FlutterBackgroundAndroidConfig(
    notificationTitle: "Cámara en segundo plano",
    notificationText: "La cámara está activa en segundo plano",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon:
        AndroidResource(name: 'background_icon', defType: 'drawable'),
  );
  bool cameraInitialized =
      await FlutterBackground.initialize(androidConfig: androidConfigCamera);
  if (cameraInitialized) {
    await FlutterBackground.enableBackgroundExecution();
  }
}

// Función para solicitar permisos
Future<void> _requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.ignoreBatteryOptimizations,
  ].request();
}

// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeModel(),  // Proveedor para la gestión del tema
      child: Consumer<ThemeModel>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Navigation Basics',
            theme: theme.isDarkMode ? ThemeData.dark() : ThemeData.light(),  // Cambia el tema según el modo seleccionado
            home: MyAppHome(),  // Define la pantalla principal
          );
        },
      ),
    );
  }
}

// Clase para la gestión del tema de la aplicación
class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = false;  // Variable para controlar el modo oscuro
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;  // Alterna el modo oscuro
    notifyListeners();  // Notifica a los oyentes para actualizar el estado
  }
}

// Clase para la pantalla principal de la aplicación
class MyAppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Primera pantalla'),  // Título de la aplicación
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SensorScreen()),  // Navega a la pantalla del sensor
                );
              },
              child: Text('Segunda pantalla'),  // Texto del botón
            ),
            SizedBox(height: 20),  // Espaciador vertical
            Consumer<ThemeModel>(
              builder: (context, theme, _) {
                return ElevatedButton(
                  onPressed: theme.toggleTheme,  // Alterna el tema de la aplicación
                  child: Text(theme.isDarkMode ? 'Modo Claro' : 'Modo Oscuro'),  // Texto del botón según el tema
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

