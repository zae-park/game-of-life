import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내 첫 플러터 앱',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('안녕 플러터!'),
        ),
        body: const Center(
          child: Text('여기서 시작해볼까?'),
        ),
      ),
    );
  }
}
