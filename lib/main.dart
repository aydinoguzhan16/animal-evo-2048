import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const AnimalEvo2048App());
}

class AnimalEvo2048App extends StatelessWidget {
  const AnimalEvo2048App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Evo 2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF65E3B)),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
