import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../core/bluetooth_service.dart';

class BluetoothView extends StatefulWidget {
  @override
  _BluetoothViewState createState() => _BluetoothViewState();
}

class _BluetoothViewState extends State<BluetoothView> {
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _buscarDispositivos();
  }

  void _buscarDispositivos() async {
    List<BluetoothDevice> dispositivosEmparejados =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _devices = dispositivosEmparejados;
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
            Expanded(
              child: _devices.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(_devices[index].name ?? "Dispositivo Desconocido"),
                          subtitle: Text(_devices[index].address),
                          onTap: () {
                            bluetoothService.conectarDispositivo(_devices[index]);
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
