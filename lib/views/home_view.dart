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
                // Convertimos el texto a Uint8List antes de enviarlo
                Uint8List mensajeEnBytes = Uint8List.fromList(_textController.text.codeUnits);
                bluetoothService.enviarTrama(mensajeEnBytes);
                _textController.clear();
              },
              child: Text("Enviar Mensaje"),
            ),
          ],
        ),
      ),
    );
  }
}



