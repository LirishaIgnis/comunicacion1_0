import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/bluetooth_service.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Comunicación Bluetooth")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.game);
              },
              child: Text("Ir al Marcador"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.bluetooth);
              },
              child: Text("Conectar Bluetooth"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Escribe un mensaje",
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Uint8List mensajeEnBytes = Uint8List.fromList(_textController.text.codeUnits);
                bluetoothService.enviarTrama(mensajeEnBytes);
                _textController.clear();
              },
              child: Text("Enviar Mensaje"),
            ),
            SizedBox(height: 20),

            // Botón para enviar la primera trama
            ElevatedButton(
              onPressed: () {
                Uint8List trama1 = Uint8List.fromList([
                  0xAA, 0xAB, 0xAC, 0x06, 0x59, 0x98, 0x08, 0x05, 0x11, 0x34, 0x24, 0xAD
                ]);
                bluetoothService.enviarTrama(trama1);
              },
              child: Text("Enviar Trama 1"),
            ),
            SizedBox(height: 10),

            // Botón para enviar la segunda trama
            ElevatedButton(
              onPressed: () {
                Uint8List trama2 = Uint8List.fromList([
                  0xAA, 0xAB, 0xAC, 0x02, 0x59, 0x98, 0x08, 0x05, 0x11, 0x34, 0x24, 0xAD
                ]);
                bluetoothService.enviarTrama(trama2);
              },
              child: Text("Enviar Trama 2"),
            ),
          ],
        ),
      ),
    );
  }
}
