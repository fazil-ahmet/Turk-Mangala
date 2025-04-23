import 'package:flutter/material.dart';
import 'game_fronted.dart';

void main() {
  runApp(const MangalaApp());
}

class MangalaApp extends StatelessWidget {
  const MangalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MangalaGamePage(),
    );
  }
}