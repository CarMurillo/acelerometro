
import 'package:flutter/material.dart';  // Importa la librería de Flutter para la interfaz de usuario
import 'package:sensors_plus/sensors_plus.dart';  // Importa la librería para el uso de sensores
import 'package:camera/camera.dart';  // Importa la librería para el uso de la cámara
import 'dart:math';  // Importa la librería matemática para realizar cálculos

// Define una clase que representa la pantalla del sensor y extiende StatefulWidget
class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();  // Crea el estado asociado con esta pantalla
}

// Define el estado de la pantalla del sensor
class _SensorScreenState extends State<SensorScreen> {
  AccelerometerEvent? _accelerometerValues;  // Variable para almacenar los valores del acelerómetro
  late CameraController _cameraController;  // Controlador para la cámara
  bool _isFlashOn = false;  // Variable para controlar el estado del flash
  int _shakeCount = 0;  // Contador para el número de sacudidas

  @override
  void initState() {
    super.initState();
    _initializeSensor();  // Inicializa el sensor del acelerómetro
    _initializeCamera();  // Inicializa la cámara
  }

  // Función para inicializar el sensor del acelerómetro
  void _initializeSensor() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = event;  // Actualiza los valores del acelerómetro
        // Calcula la magnitud de la aceleración
        double acceleration = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
        if (acceleration > 30) {  // Si la aceleración supera un umbral (30 en este caso)
          _shakeCount++;  // Incrementa el contador de sacudidas
          if (_shakeCount == 2) {  // Si el contador es 2, cambia el estado del flash
            _toggleFlashlight();
          } else if (_shakeCount == 4) {  // Si el contador es 4, cambia el estado del flash y resetea el contador
            _toggleFlashlight();
            _shakeCount = 0;  
          }
        }
      });
    });
  }

  // Función para inicializar la cámara
  void _initializeCamera() {
    _cameraController = CameraController(
      CameraDescription(
        name: '0',  // Nombre de la cámara
        lensDirection: CameraLensDirection.back,  // Dirección del lente (trasero)
        sensorOrientation: 0,  // Orientación del sensor (ajústalo según la orientación del dispositivo)
      ),
      ResolutionPreset.low,  // Resolución de la cámara (baja en este caso)
    );
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
    });
  }

  // Función para alternar el estado del flash
  void _toggleFlashlight() {
    if (_isFlashOn) {
      _cameraController.setFlashMode(FlashMode.off);  // Apaga el flash
    } else {
      _cameraController.setFlashMode(FlashMode.torch);  // Enciende el flash en modo torch
    }
    _isFlashOn = !_isFlashOn;  // Cambia el estado del flash
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acelerómetro'),  // Título de la aplicación
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Acelerómetro:',
              style: TextStyle(fontSize: 20),  // Estilo del texto
            ),
            SizedBox(height: 10),  // Espaciador vertical
            Text('Agitaciones: $_shakeCount'),  // Muestra el número de sacudidas
            SizedBox(height: 10),
            _accelerometerValues != null  // Si hay valores del acelerómetro, los muestra
                ? Column(
                    children: [
                      Text('Valor X: ${_accelerometerValues!.x}'),  // Valor en el eje X
                      Text('Valor Y: ${_accelerometerValues!.y}'),  // Valor en el eje Y
                      Text('Valor Z: ${_accelerometerValues!.z}'),  // Valor en el eje Z
                    ],
                  )
                : Text('Esperando datos...'),  // Si no hay valores, muestra un mensaje de espera
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();  // Libera los recursos de la cámara cuando el widget se elimina
    super.dispose();
  }
}
