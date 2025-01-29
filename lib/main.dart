import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'controllers/time_controller.dart';
import 'core/bluetooth_service.dart';
import 'core/app_routes.dart';
import 'models/game_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothService()), // Instancia de BluetoothService
        Provider(create: (_) => GameState()), // GameState ya no necesita ser un ChangeNotifier
        ChangeNotifierProvider(
          create: (context) => GameController(
            Provider.of<GameState>(context, listen: false), 
            Provider.of<BluetoothService>(context, listen: false)
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TimeController(
            Provider.of<GameState>(context, listen: false), 
            Provider.of<BluetoothService>(context, listen: false)
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bluetooth 2.0',
        theme: ThemeData.dark(),
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
      ),
    );
  }
}


