import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/bluetooth_service.dart';

class GameController extends ChangeNotifier {
  final GameState _gameState;
  final BluetoothService _bluetoothService;
  bool _bitOscilacion = false; // Alterna entre 6 y 2

  GameController(this._gameState, this._bluetoothService);

  GameState get gameState => _gameState;

  /// **Actualiza y envía la trama estándar**
  void _actualizarTrama() {
    _bitOscilacion = !_bitOscilacion; // Alternar entre 6 y 2

    // Generar la trama correctamente codificada y enviarla
    Uint8List trama = _gameState.generarTramaEstadoPartido(_bitOscilacion ? 6 : 2);
    _bluetoothService.enviarTrama(trama);
  }

  /// **Genera y envía la trama de faltas tomando los datos actuales del estado del juego**
  void _enviarTramaFaltas() {
    Uint8List tramaFaltas = _gameState.generarTramaFaltas(
      bitOscilacion: _bitOscilacion ? 6 : 2,
    );
    _bluetoothService.enviarTrama(tramaFaltas);
  }

  // *** Funciones para modificar el marcador ***
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

  // *** Funciones para modificar las faltas y enviar la trama de faltas ***
  void aumentarFaltasLocal() {
    _gameState.faltasLocal++;
    notifyListeners();
    _enviarTramaFaltas();
  }

  void disminuirFaltasLocal() {
    if (_gameState.faltasLocal > 0) {
      _gameState.faltasLocal--;
      notifyListeners();
      _enviarTramaFaltas();
    }
  }

  void aumentarFaltasVisitante() {
    _gameState.faltasVisitante++;
    notifyListeners();
    _enviarTramaFaltas();
  }

  void disminuirFaltasVisitante() {
    if (_gameState.faltasVisitante > 0) {
      _gameState.faltasVisitante--;
      notifyListeners();
      _enviarTramaFaltas();
    }
  }

  // *** Función para cambiar el periodo ***
  void cambiarPeriodo() {
    _gameState.periodo++;
    _gameState.minutos = 0;
    _gameState.segundos = 0;
    notifyListeners();
    _actualizarTrama();
  }

  // *** Función para reiniciar los marcadores y el tiempo ***
  void reiniciarMarcadoresYTiempo() {
    _gameState.marcadorLocal = 0;
    _gameState.marcadorVisitante = 0;
    _gameState.minutos = 0;
    _gameState.segundos = 0;
    _gameState.faltasLocal = 0;
    _gameState.faltasVisitante = 0;
    notifyListeners();
    _actualizarTrama();
  }
}
