// lib/widgets/control_panel.dart

import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onLoad;
  final VoidCallback onLoadImage;

  const ControlPanel({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onSave,
    required this.onLoad,
    required this.onLoadImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onStart,
          child: const Text('시작'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onStop,
          child: const Text('일시정지'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onReset,
          child: const Text('초기화'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onSave,
          child: const Text('패턴 저장'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onLoad,
          child: const Text('패턴 로드'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onLoadImage,
          child: const Text('이미지 로드'),
        ),
      ],
    );
  }
}
