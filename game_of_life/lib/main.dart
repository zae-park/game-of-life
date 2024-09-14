// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/game_page.dart';

void main() => runApp(const GameOfLifeApp());

class GameOfLifeApp extends StatelessWidget {
  const GameOfLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway\'s Game of Life',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameOfLifePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
