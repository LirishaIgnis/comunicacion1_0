import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/game_view.dart';
import '../views/bluetooth_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String bluetooth = '/bluetooth';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => HomeView(),
    game: (context) => GameView(),
    bluetooth: (context) => BluetoothView(),
  };
}
