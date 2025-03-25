import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:async';

class BluetoothService extends ChangeNotifier {
  fbp.FlutterBluePlus flutterBlue = fbp.FlutterBluePlus();
  fbp.BluetoothDevice? _dispositivoConectado;
  fbp.BluetoothCharacteristic? _characteristic;
  bool _isConnected = false;
  bool _bluetoothEnabled = false;
  bool _permissionsGranted = false;

  String? _nombreDispositivoConectado; // ✅ Nuevo: guarda el nombre real leído del advertisement

  StreamController<List<fbp.ScanResult>> _scanController = StreamController.broadcast();
  StreamSubscription? _scanSubscription;

  bool get isConnected => _isConnected;
  bool get bluetoothEnabled => _bluetoothEnabled;
  bool get permissionsGranted => _permissionsGranted;
  fbp.BluetoothDevice? get dispositivoConectado => _dispositivoConectado;

  /// ✅ Getter para mostrar el nombre del dispositivo conectado en la UI
  String get nombreDispositivoConectado =>
      _nombreDispositivoConectado ??
      _dispositivoConectado?.platformName ??
      _dispositivoConectado?.remoteId.str ??
      "Desconocido";

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
  Stream<List<fbp.ScanResult>> escanearDispositivos() {
    if (_isConnected) {
      print("⚠️ No se inicia el escaneo porque hay un dispositivo conectado.");
      return Stream.empty(); // No escanea si ya hay una conexión
    }

    try {
      print("🔍 Iniciando escaneo de dispositivos...");
      fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      _scanSubscription?.cancel();
      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        if (!_scanController.isClosed) {
          _scanController.add(results);
        }
      });
    } catch (e) {
      print("❌ Error al escanear dispositivos: $e");
    }

    return _scanController.stream;
  }

  /// **Detener escaneo y liberar memoria**
  void detenerEscaneo() {
    print("🛑 Deteniendo escaneo...");
    _scanSubscription?.cancel();
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
      // ✅ Guardamos el nombre desde advertising si estuviera disponible
      final scanResult = await _buscarScanResultPorDevice(device);
      _nombreDispositivoConectado = scanResult?.advertisementData.localName;

      print("🔁 Conectando a ${_nombreDispositivoConectado ?? device.platformName ?? device.remoteId}...");

      // **Detener escaneo antes de conectar**
      detenerEscaneo();
      fbp.FlutterBluePlus.stopScan();

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
      print('✅ Conectado a $nombreDispositivoConectado');
    } catch (e) {
      _isConnected = false;
      _dispositivoConectado = null;
      print('❌ Error al conectar: $e');
      notifyListeners();
    }
  }

  /// ✅ Busca el último ScanResult con info del dispositivo
  Future<fbp.ScanResult?> _buscarScanResultPorDevice(fbp.BluetoothDevice device) async {
    final resultsList = await fbp.FlutterBluePlus.scanResults.first;
    try {
      return resultsList.firstWhere(
        (result) => result.device.remoteId == device.remoteId,
      );
    } catch (e) {
      // En caso de que no se encuentre, crear un ScanResult manual con advertencia
      print("⚠️ ScanResult no encontrado para el dispositivo ${device.remoteId}");
      return fbp.ScanResult(
        device: device,
        advertisementData:  fbp.AdvertisementData(
          advName: "",
          txPowerLevel: null,
          appearance: 0,
          connectable: false,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
        ),
        rssi: 0,
        timeStamp: DateTime.now(),
      );
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
        print("🔌 Desconectando...");
        await _dispositivoConectado!.disconnect();
        _isConnected = false;
        _dispositivoConectado = null;
        _characteristic = null;
        notifyListeners();
        print("✅ Desconectado correctamente.");
      } catch (e) {
        print("❌ Error al desconectar: $e");
      }
    }
  }

  /// **Liberar recursos al cerrar la aplicación**
  @override
  void dispose() {
    detenerEscaneo();
    _scanController.close();
    super.dispose();
  }
}
