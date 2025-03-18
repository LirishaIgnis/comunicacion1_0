import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

class BluetoothService extends ChangeNotifier {
  fbp.FlutterBluePlus flutterBlue = fbp.FlutterBluePlus();
  fbp.BluetoothDevice? _dispositivoConectado;
  fbp.BluetoothCharacteristic? _characteristic;
  bool _isConnected = false;
  bool _bluetoothEnabled = false;
  bool _permissionsGranted = false;

  bool get isConnected => _isConnected;
  bool get bluetoothEnabled => _bluetoothEnabled;
  bool get permissionsGranted => _permissionsGranted;
  fbp.BluetoothDevice? get dispositivoConectado => _dispositivoConectado;

  BluetoothService() {
    _checkBluetoothStatus();
  }

  /// **Verifica si el Bluetooth está activado**
  Future<void> _checkBluetoothStatus() async {
    _bluetoothEnabled = await fbp.FlutterBluePlus.isOn;
    notifyListeners();
  }

  /// **Solicita permisos de Bluetooth en Android 12+**
  Future<void> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      _permissionsGranted = true;
      print("✅ Permisos concedidos");
    } else {
      _permissionsGranted = false;
      print("❌ Permisos denegados");
    }
    _bluetoothEnabled = await fbp.FlutterBluePlus.isOn;
    notifyListeners();
  }

  /// **Escanea dispositivos BLE cercanos**
  Stream<List<fbp.ScanResult>> escanearDispositivos() async* {
    try {
      fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      yield* fbp.FlutterBluePlus.scanResults;
    } catch (e) {
      print("❌ Error al escanear dispositivos: $e");
    } finally {
      fbp.FlutterBluePlus.stopScan();
    }
  }

  /// **Conectar o desconectar un dispositivo**
  Future<void> conectarODesconectar(fbp.BluetoothDevice dispositivo) async {
    if (estaConectado(dispositivo)) {
      await desconectar();
    } else {
      await conectarDispositivo(dispositivo);
    }
  }

  /// **Verifica si un dispositivo está conectado**
  bool estaConectado(fbp.BluetoothDevice dispositivo) {
    return _isConnected && _dispositivoConectado?.remoteId == dispositivo.remoteId;
  }

  /// **Conectar a un dispositivo BLE**
  Future<void> conectarDispositivo(fbp.BluetoothDevice device) async {
    try {
      print("🔄 Conectando a ${device.platformName}...");
      await device.connect();
      _dispositivoConectado = device;
      _isConnected = true;

      // **Descubrir servicios y características**
      List<fbp.BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _characteristic = characteristic;
            break;
          }
        }
      }

      if (_characteristic != null) {
        print("✅ Característica GATT encontrada");
      } else {
        print("⚠️ No se encontró una característica GATT de escritura");
      }

      notifyListeners();
      print('✅ Conectado a ${device.platformName}');
    } catch (e) {
      _isConnected = false;
      _dispositivoConectado = null;
      print('❌ Error al conectar: $e');
      notifyListeners();
    }
  }

  /// **Enviar datos a través de BLE (GATT)**
  Future<void> enviarTrama(Uint8List trama) async {
    if (_isConnected && _characteristic != null) {
      try {
        await _characteristic!.write(trama);
        print("📤 Trama enviada: ${trama.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}");
      } catch (e) {
        print("❌ Error al enviar trama: $e");
      }
    } else {
      print("❌ No hay conexión activa o característica GATT no encontrada");
    }
  }

  /// **Desconectar dispositivo BLE**
  Future<void> desconectar() async {
    if (_dispositivoConectado != null) {
      try {
        await _dispositivoConectado!.disconnect();
        _isConnected = false;
        _dispositivoConectado = null;
        _characteristic = null;
        notifyListeners();
        print("🔌 Desconectado de Bluetooth");
      } catch (e) {
        print("❌ Error al desconectar: $e");
      }
    }
  }
}


