import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  bool _bluetoothEnabled = false;
  bool _permissionsGranted = false;

  bool get isConnected => _isConnected;
  bool get bluetoothEnabled => _bluetoothEnabled;
  bool get permissionsGranted => _permissionsGranted;

  BluetoothService() {
    _checkBluetoothStatus();
  }

  /// Verifica si el Bluetooth está habilitado en el dispositivo.
  Future<void> _checkBluetoothStatus() async {
    bool enabled = (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
    _bluetoothEnabled = enabled;
    notifyListeners();
  }

  /// Solicita permisos para habilitar Bluetooth en caso de que esté deshabilitado.
  Future<void> requestPermissions() async {
    bool granted = (await FlutterBluetoothSerial.instance.requestEnable()) ?? false;
    _permissionsGranted = granted;
    _bluetoothEnabled = granted;
    notifyListeners();
  }

  /// Conecta con un dispositivo Bluetooth seleccionado.
  Future<void> conectarDispositivo(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      notifyListeners();
      print('✅ Conectado a ${device.name}');
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      print('❌ Error al conectar: $e');
    }
  }

  /// Enviar un mensaje en formato de texto al dispositivo conectado.
  void enviarMensaje(String mensaje) {
    if (_connection != null && _connection!.isConnected) {
      Uint8List data = Uint8List.fromList(mensaje.codeUnits);
      _connection!.output.add(data);
      _connection!.output.allSent.then((_) {
        print("📨 Mensaje enviado: $mensaje");
      });
    } else {
      print("⚠ No hay conexión activa para enviar el mensaje.");
    }
  }

  /// Enviar una trama en formato binario al dispositivo Bluetooth.
void enviarTrama(List<int> trama) {
  if (_connection != null && _connection!.isConnected) {
    Uint8List data = Uint8List.fromList(trama);
    _connection!.output.add(data);
    _connection!.output.allSent.then((_) {
      print("📨 Trama enviada: ${trama.map((e) => e.toRadixString(16)).toList()}");
    });
  } else {
    print("⚠ No hay conexión activa para enviar la trama.");
  }
}





  /// Desconectar del dispositivo Bluetooth.
  void desconectar() {
    if (_connection != null) {
      _connection?.close();
      _connection = null;
      _isConnected = false;
      notifyListeners();
      print("🔌 Bluetooth desconectado.");
    } else {
      print("⚠ No hay conexión activa para desconectar.");
    }
  }
}
