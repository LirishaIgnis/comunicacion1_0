import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';

class BluetoothService extends ChangeNotifier {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  bool _bluetoothEnabled = false;
  bool _permissionsGranted = false;
  BluetoothDevice? _dispositivoConectado;

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

  /// **Obtiene los dispositivos emparejados**
  Future<List<BluetoothDevice>> obtenerDispositivosEmparejados() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  /// **Verifica si un dispositivo específico está conectado**
  bool estaConectado(BluetoothDevice dispositivo) {
    return _isConnected && _dispositivoConectado?.address == dispositivo.address;
  }

  /// **Conecta o desconecta un dispositivo según su estado actual**
  Future<void> conectarODesconectar(BluetoothDevice dispositivo) async {
    if (estaConectado(dispositivo)) {
      desconectar();
    } else {
      await conectarDispositivo(dispositivo);
    }
  }

  /// **Conecta un dispositivo Bluetooth**
  Future<void> conectarDispositivo(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _dispositivoConectado = device;
      _isConnected = true;
      notifyListeners();
      print('Conectado a ${device.name}');
    } catch (e) {
      _isConnected = false;
      _dispositivoConectado = null;
      notifyListeners();
      print('Error al conectar: $e');
    }
  }

  /// **Envía la trama de datos**
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

  /// **Desconecta el dispositivo Bluetooth**
  void desconectar() {
    _connection?.close();
    _connection = null;
    _isConnected = false;
    _dispositivoConectado = null;
    notifyListeners();
    print("Desconectado de Bluetooth");
  }
}

