// lib/widgets/grid_painter.dart

import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final List<List<int>> board;
  final double cellSize;

  GridPainter(this.board, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final deadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        Rect rect =
            Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize);
        if (board[i][j] == 1) {
          canvas.drawRect(rect, paint);
        } else {
          canvas.drawRect(rect, deadPaint);
        }
      }
    }

    // 그리드 라인 그리기 (옵션)
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= board.length; i++) {
      // 수평선
      canvas.drawLine(Offset(0, i * cellSize),
          Offset(board[0].length * cellSize, i * cellSize), gridPaint);
    }

    for (int j = 0; j <= board[0].length; j++) {
      // 수직선
      canvas.drawLine(Offset(j * cellSize, 0),
          Offset(j * cellSize, board.length * cellSize), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
