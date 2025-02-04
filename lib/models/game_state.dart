import 'dart:typed_data';

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

  /// **Función para convertir un valor decimal al formato hexadecimal especificado**
  int convertirDecimalAHex(int valor) {
    int parteEntera = valor ~/ 10;
    int parteUnidades = valor % 10;
    return (parteEntera << 4) | parteUnidades;  // Combina decenas y unidades
  }

  /// **Codifica las centenas del marcador local y visitante en un solo byte**
  int codificarCentenas(int marcadorLocal, int marcadorVisitante) {
    int centenaLocal = marcadorLocal ~/ 100;
    int centenaVisitante = marcadorVisitante ~/ 100;
    return (centenaLocal << 4) | centenaVisitante;
  }

  /// **Genera la trama completa con la codificación correcta**
  Uint8List generarTramaEstadoPartido(int bitOscilacion) {
    return Uint8List.fromList([
      0xAA, 0xAB, 0xAC,  // Encabezado
      0x00,  // Indica si el tiempo es menor a un minuto (ajustable si es necesario)
      convertirDecimalAHex(minutos),  // Minutos codificados
      convertirDecimalAHex(segundos),  // Segundos codificados
      convertirDecimalAHex(marcadorLocal % 100),  // Decenas y unidades del marcador local (reinicia después de 99)
      convertirDecimalAHex(marcadorVisitante % 100),  // Decenas y unidades del marcador visitante
      codificarCentenas(marcadorLocal, marcadorVisitante),  // Centenas combinadas
      0x03,  // Tiempo local (por ahora estático)
      ((bitOscilacion & 0x0F) << 4) | (periodo & 0x0F),  // Bit oscilante y periodo combinados
      0xAD  // Fin de la trama
    ]);
  }
}



