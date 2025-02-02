import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/bluetooth_service.dart';
import '../controllers/game_controller.dart';

class TimeController extends ChangeNotifier {
  final GameState _gameState;
  final BluetoothService _bluetoothService;
  Timer? _timer;
  bool _bitOscilacion = false; // Alterna entre 6 y 2

  TimeController(this._gameState, this._bluetoothService);

  GameState get gameState => _gameState;

  void iniciarTiempo() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        _actualizarTiempo();
      });
    }
  }

  void pausarTiempo() {
    _timer?.cancel();
    _timer = null;
  }

  /// **Ahora "Reiniciar" pone en 0 el tiempo, periodo y marcadores**
  void reiniciarTiempo(GameController gameController) {
    _timer?.cancel();
    _timer = null;
    gameController.reiniciarMarcadoresYTiempo();
    notifyListeners();
  }

  void _actualizarTiempo() {
    _bitOscilacion = !_bitOscilacion; // Alternar entre 6 y 2

    if (_gameState.segundos == 59) {
      _gameState.minutos++;
      _gameState.segundos = 0;
    } else {
      _gameState.segundos++;
    }

    notifyListeners();
    
    // Generar y enviar la trama con el tiempo actualizado
    List<int> trama = _gameState.generarTramaEstadoPartido(_bitOscilacion ? 6 : 2);
    _bluetoothService.enviarTrama(trama);
  }
}
