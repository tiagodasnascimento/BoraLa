import 'package:flutter/material.dart';

import 'features/discovery/presentation/map_screen.dart';

class BoraLaApp extends StatelessWidget {
  const BoraLaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoraLá',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapScreen();
  }
}
