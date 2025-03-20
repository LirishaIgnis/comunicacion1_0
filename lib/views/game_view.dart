import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'dart:async';
import '../controllers/game_controller.dart';
import '../controllers/time_controller.dart';
import '../core/bluetooth_service.dart';
import 'home_view.dart';

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  fbp.BluetoothDevice? _selectedDevice;
  List<fbp.ScanResult> _devices = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarEscaneo();
  }

  /// **Suscribirse al escaneo de dispositivos desde `BluetoothService`**
  void _iniciarEscaneo() {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    _scanSubscription?.cancel(); // Cancelar escaneo previo si existe

    _scanSubscription = bluetoothService.escanearDispositivos().listen((results) {
      if (mounted) {
        setState(() {
          _devices = results;
        });
      }
    });
  }

  /// **Cancelar escaneo al salir de GameView**
  @override
  void dispose() {
    _scanSubscription?.cancel(); // Cancela la suscripción al escaneo
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context);
    final timeController = Provider.of<TimeController>(context);
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text("Marcador", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, size: 30),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: _buildBluetoothMenu(bluetoothService),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${timeController.gameState.minutos}:${timeController.gameState.segundos.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: _buildScoreColumn(
                    "Local",
                    gameController.gameState.marcadorLocal,
                    Colors.blue,
                    gameController.aumentarMarcadorLocal,
                    gameController.disminuirMarcadorLocal,
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Text("Periodo", style: TextStyle(fontSize: 30, color: Colors.white)),
                      SizedBox(height: 5),
                      Text("${gameController.gameState.periodo}",
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                      ElevatedButton(
                        onPressed: () {
                          gameController.cambiarPeriodo();
                          timeController.reiniciarTiempo(gameController);
                        },
                        child: Text("Siguiente", style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: _buildScoreColumn(
                    "Visitante",
                    gameController.gameState.marcadorVisitante,
                    Colors.red,
                    gameController.aumentarMarcadorVisitante,
                    gameController.disminuirMarcadorVisitante,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            _buildTimeControlButtons(timeController, gameController),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "homeButton",
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeView()));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.home, size: 30),
      ),
    );
  }

  /// **Construye el menú de Bluetooth**
  Widget _buildBluetoothMenu(BluetoothService bluetoothService) {
    return Drawer(
      child: Container(
        color: Colors.blueGrey[800],
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dispositivos Bluetooth",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<fbp.BluetoothDevice>(
              dropdownColor: Colors.grey[850],
              value: _selectedDevice,
              items: _devices.map((scanResult) {
                var device = scanResult.device;
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.platformName ?? "Desconocido", style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[700],
                labelText: "Seleccionar dispositivo",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedDevice != null
                  ? () => bluetoothService.conectarODesconectar(_selectedDevice!)
                  : null,
              child: Text(bluetoothService.isConnected ? "Desconectar" : "Conectar",
                  style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: bluetoothService.isConnected ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Construye una columna para los puntajes**
  Widget _buildScoreColumn(String label, int score, Color color, VoidCallback onIncrease, VoidCallback onDecrease) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("$score", style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onIncrease,
              child: Text("+", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: onDecrease,
              child: Text("-", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  /// **Construye los botones para el control del tiempo**
  Widget _buildTimeControlButtons(TimeController timeController, GameController gameController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: timeController.iniciarTiempo, child: Text("Iniciar")),
        SizedBox(width: 15),
        ElevatedButton(onPressed: timeController.pausarTiempo, child: Text("Pausar")),
        SizedBox(width: 15),
        ElevatedButton(onPressed: gameController.reiniciarMarcadoresYTiempo, child: Text("Reiniciar")),
      ],
    );
  }
}

