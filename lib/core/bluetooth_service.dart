import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';

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

  Future<void> _checkBluetoothStatus() async {
    bool enabled = (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
    _bluetoothEnabled = enabled;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    bool granted = (await FlutterBluetoothSerial.instance.requestEnable()) ?? false;
    _permissionsGranted = granted;
    _bluetoothEnabled = granted;
    notifyListeners();
  }

  Future<void> conectarDispositivo(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      notifyListeners();
      print('Conectado a ${device.name}');
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      print('Error al conectar: $e');
    }
  }

  void enviarTrama(Uint8List trama) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(trama);
      _connection!.output.allSent.then((_) {
        print("Trama enviada: ${trama.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}");
      });
    } else {
      print("No hay conexión activa");
    }
  }

  void desconectar() {
    _connection?.close();
    _connection = null;
    _isConnected = false;
    notifyListeners();
    print("Desconectado de Bluetooth");
  }
}

