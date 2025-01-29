import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/bluetooth_service.dart';

class GameController extends ChangeNotifier {
  final GameState _gameState;
  final BluetoothService _bluetoothService;
  bool _bitOscilacion = false; // Alterna entre 6 y 2

  GameController(this._gameState, this._bluetoothService);

  GameState get gameState => _gameState;

  void _actualizarTrama() {
    _bitOscilacion = !_bitOscilacion; // Alternar entre 6 y 2
    List<int> trama = _gameState.generarTramaEstadoPartido(_bitOscilacion ? 6 : 2);
    _bluetoothService.enviarTrama(trama);
  }

  void aumentarMarcadorLocal() {
    _gameState.marcadorLocal++;
    notifyListeners();
    _actualizarTrama();
  }

  void disminuirMarcadorLocal() {
    if (_gameState.marcadorLocal > 0) {
      _gameState.marcadorLocal--;
      notifyListeners();
      _actualizarTrama();
    }
  }

  void aumentarMarcadorVisitante() {
    _gameState.marcadorVisitante++;
    notifyListeners();
    _actualizarTrama();
  }

  void disminuirMarcadorVisitante() {
    if (_gameState.marcadorVisitante > 0) {
      _gameState.marcadorVisitante--;
      notifyListeners();
      _actualizarTrama();
    }
  }

  /// **Cuando cambia el periodo, el tiempo vuelve a 0:00**
  void cambiarPeriodo() {
    _gameState.periodo++;
    _gameState.minutos = 0;
    _gameState.segundos = 0;
    notifyListeners();
    _actualizarTrama();
  }

  /// **Reiniciar los marcadores sin cambiar el periodo**
  void reiniciarMarcadores() {
    _gameState.marcadorLocal = 0;
    _gameState.marcadorVisitante = 0;
    notifyListeners();
    _actualizarTrama();
  }
}



