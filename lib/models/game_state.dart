class GameState {
  int minutos;
  int segundos;
  int marcadorLocal;
  int marcadorVisitante;
  int periodo;

  GameState({
    this.minutos = 0,
    this.segundos = 0,
    this.marcadorLocal = 0,
    this.marcadorVisitante = 0,
    this.periodo = 1,
  });

  /// **Genera la trama completa con los valores correctos**
  List<int> generarTramaEstadoPartido(int bitOscilacion) {
    return [
      0xAA, 0xAB, 0xAC, 0x00, // Encabezado e identificador de la trama
      minutos, segundos, // Tiempo
      ((marcadorLocal ~/ 10) << 4) + (marcadorLocal % 10), // Decenas y unidades local
      ((marcadorVisitante ~/ 10) << 4) + (marcadorVisitante % 10), // Decenas y unidades visitante
      ((marcadorLocal ~/ 100) << 4) + (marcadorVisitante ~/ 100), // Centenas combinadas
      3, // Tiempo local (estático)
      (bitOscilacion << 4) + periodo, // Bit oscilación en la primera mitad, periodo en la segunda mitad
      0xAD // Fin de la trama
    ];
  }
}
