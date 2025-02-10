import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/time_controller.dart';
import '../core/bluetooth_service.dart';

class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context);
    final timeController = Provider.of<TimeController>(context);
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text("Marcador", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sección de botones de Bluetooth
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBluetoothButton("Verificar", Icons.check_circle, Colors.blue, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bluetoothService.isConnected
                          ? "Bluetooth conectado"
                          : "Bluetooth no conectado"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }),
                _buildBluetoothButton("Conectar", Icons.bluetooth, Colors.green, () {
                  // Aquí iría la lógica para seleccionar y conectar un dispositivo Bluetooth
                }),
                _buildBluetoothButton("Desconectar", Icons.bluetooth_disabled, Colors.red, bluetoothService.desconectar),
              ],
            ),
            SizedBox(height: 20),

            // Sección del reloj (Tiempo)
            Text(
              "${timeController.gameState.minutos}:${timeController.gameState.segundos.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 30),

            // Sección de Marcadores, Periodo y Faltas
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
                          timeController.reiniciarTiempo(gameController); // Reinicia el tiempo al cambiar el periodo
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
            SizedBox(height: 20),

            // Sección de control de faltas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: _buildFoulsColumn(
                    "Faltas Local",
                    gameController.gameState.faltasLocal,
                    Colors.blue,
                    gameController.aumentarFaltasLocal,
                    gameController.disminuirFaltasLocal,
                  ),
                ),
                Flexible(
                  child: _buildFoulsColumn(
                    "Faltas Visitante",
                    gameController.gameState.faltasVisitante,
                    Colors.red,
                    gameController.aumentarFaltasVisitante,
                    gameController.disminuirFaltasVisitante,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Botones de control del reloj
            _buildTimeControlButtons(timeController, gameController),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar el marcador de cada equipo con sus botones
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
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: onDecrease,
              child: Text("-", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget para mostrar y modificar las faltas
  Widget _buildFoulsColumn(String label, int fouls, Color color, VoidCallback onIncrease, VoidCallback onDecrease) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("$fouls", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onIncrease,
              child: Text("+", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: onDecrease,
              child: Text("-", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Botones para controlar el reloj
  Widget _buildTimeControlButtons(TimeController timeController, GameController gameController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: timeController.iniciarTiempo,
          child: Text("Iniciar", style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        SizedBox(width: 15),
        ElevatedButton(
          onPressed: timeController.pausarTiempo,
          child: Text("Pausar", style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        SizedBox(width: 15),
        ElevatedButton(
          onPressed: gameController.reiniciarMarcadoresYTiempo,
          child: Text("Reiniciar", style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }

  /// Botón de Bluetooth con texto y un ícono
  Widget _buildBluetoothButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 30),
      label: Text(label, style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
