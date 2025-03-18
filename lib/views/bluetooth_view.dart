import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import '../core/bluetooth_service.dart';

class BluetoothView extends StatefulWidget {
  @override
  _BluetoothViewState createState() => _BluetoothViewState();
}

class _BluetoothViewState extends State<BluetoothView> {
  List<fbp.ScanResult> _devices = []; // Lista de dispositivos BLE descubiertos

  @override
  void initState() {
    super.initState();
    _buscarDispositivos();
  }

  /// **Escanea dispositivos BLE cercanos**
  void _buscarDispositivos() async {
    setState(() {
      _devices = []; // Limpiamos la lista antes de escanear
    });

    fbp.FlutterBluePlus flutterBlue = fbp.FlutterBluePlus();

    // Iniciar el escaneo de dispositivos BLE
    fbp.FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    // Escuchar los resultados del escaneo
    fbp.FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _devices = results; // Almacenar los dispositivos detectados
      });
    });

    // Detener escaneo después de 5 segundos
    Future.delayed(Duration(seconds: 5), () {
      fbp.FlutterBluePlus.stopScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth - Estado")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              bluetoothService.bluetoothEnabled
                  ? "✅ Bluetooth Encendido"
                  : "❌ Bluetooth Apagado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              bluetoothService.permissionsGranted
                  ? "✅ Permisos Concedidos"
                  : "❌ Permisos No Concedidos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: bluetoothService.requestPermissions,
              child: Text("Verificar Bluetooth y Permisos"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _buscarDispositivos,
              child: Text("Escanear Dispositivos BLE"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _devices.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        var device = _devices[index].device;
                        return ListTile(
                          title: Text(device.platformName ?? "Dispositivo Desconocido"),
                          subtitle: Text(device.remoteId.toString()),
                          onTap: () {
                            bluetoothService.conectarDispositivo(device);
                          },
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: bluetoothService.desconectar,
              child: Text("Desconectar Bluetooth"),
            ),
          ],
        ),
      ),
    );
  }
}
