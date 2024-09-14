import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내 첫 플러터 앱',
      home: Scaffold(
        appBar: AppBar(
          title: Text('안녕 플러터!'),
        ),
        body: Center(
          child: Text('여기서 시작해볼까?'),
        ),
      ),
    );
  }
}
