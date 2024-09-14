// lib/widgets/toolbar.dart

import 'package:flutter/material.dart';
import '../pages/game_page.dart';

class Toolbar extends StatelessWidget {
  final Mode currentMode;
  final bool isEraser;
  final Function(Mode) onSwitchMode;
  final Function(bool) onToggleEraser;

  const Toolbar({
    super.key,
    required this.currentMode,
    required this.isEraser,
    required this.onSwitchMode,
    required this.onToggleEraser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.grid_on,
              color: currentMode == Mode.cell ? Colors.blue : Colors.grey),
          onPressed: () => onSwitchMode(Mode.cell),
          tooltip: 'Cell Mode',
        ),
        IconButton(
          icon: Icon(Icons.brush,
              color: currentMode == Mode.draw ? Colors.blue : Colors.grey),
          onPressed: () => onSwitchMode(Mode.draw),
          tooltip: 'Draw Mode',
        ),
        if (currentMode == Mode.draw)
          IconButton(
            icon: Icon(isEraser ? Icons.remove_circle : Icons.create),
            color: isEraser ? Colors.red : Colors.grey,
            onPressed: () => onToggleEraser(!isEraser),
            tooltip: isEraser ? 'Eraser' : 'Pen',
          ),
      ],
    );
  }
}
