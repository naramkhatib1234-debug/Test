import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';
import 'systems/audio_system.dart';
import 'systems/save_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const StackRushApp());
}

class StackRushApp extends StatefulWidget {
  const StackRushApp({super.key});

  @override
  State<StackRushApp> createState() => _StackRushAppState();
}

class _StackRushAppState extends State<StackRushApp> {
  SaveSystem? _save;
  AudioSystem? _audio;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final save = await SaveSystem.load();
    final audio = AudioSystem(save);
    // Audio setup runs in the background: it must never block the menu
    // from appearing (and a missing/slow audio backend shouldn't either).
    unawaited(audio.preload().then((_) => audio.startMusic()));
    if (!mounted) return;
    setState(() {
      _save = save;
      _audio = audio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF3D7FD9),
        brightness: Brightness.dark,
      ),
      home: _save == null || _audio == null
          ? const _SplashScreen()
          : MainMenuScreen(save: _save!, audio: _audio!),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232A6E), Color(0xFF3D7FD9), Color(0xFF6FB3F2)],
        ),
      ),
      child: const Center(
        child: Text(
          'STACK RUSH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 32,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
