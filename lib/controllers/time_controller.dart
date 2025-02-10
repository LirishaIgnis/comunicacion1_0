import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/bluetooth_service.dart';
import '../controllers/game_controller.dart';

class TimeController extends ChangeNotifier {
  final GameState _gameState;
  final BluetoothService _bluetoothService;
  Timer? _tramaTimer;
  Timer? _relojTimer;
  bool _bitOscilacion = false; // Alterna entre 6 y 2

  TimeController(this._gameState, this._bluetoothService);

  GameState get gameState => _gameState;

  void iniciarTiempo() {
    if (_tramaTimer == null && _relojTimer == null) {
      // Timer para enviar la trama cada 500 ms
      _tramaTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        _enviarTrama();
      });

      // Timer para actualizar el reloj cada 1 segundo
      _relojTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        _actualizarTiempo();
      });
    }
  }

  void pausarTiempo() {
    _tramaTimer?.cancel();
    _tramaTimer = null;
    _relojTimer?.cancel();
    _relojTimer = null;
  }

  /// **Reiniciar pone en 0 el tiempo y los marcadores (sin afectar el periodo)**
  void reiniciarTiempo(GameController gameController) {
    _tramaTimer?.cancel();
    _relojTimer?.cancel();
    _tramaTimer = null;
    _relojTimer = null;
    gameController.reiniciarMarcadoresYTiempo();
    notifyListeners();
  }

  /// **Actualiza el tiempo del reloj cada 1 segundo**
  void _actualizarTiempo() {
    if (_gameState.segundos == 59) {
      _gameState.minutos++;
      _gameState.segundos = 0;
    } else {
      _gameState.segundos++;
    }
    notifyListeners();
  }

  /// **Envía la trama cada 500 ms**
  void _enviarTrama() {
    _bitOscilacion = !_bitOscilacion; // Alternar entre 6 y 2
    Uint8List trama = _gameState.generarTramaEstadoPartido(_bitOscilacion ? 6 : 2);
    _bluetoothService.enviarTrama(trama);
  }
}
