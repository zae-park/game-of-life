import 'dart:async';
import 'package:flutter/material.dart';

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

class GameOfLifePage extends StatefulWidget {
  const GameOfLifePage({super.key});

  @override
  _GameOfLifePageState createState() => _GameOfLifePageState();
}

class _GameOfLifePageState extends State<GameOfLifePage> {
  static const int rows = 50;
  static const int cols = 50;
  static const double cellSize = 10.0;

  List<List<int>> board = List.generate(
    rows,
    (_) => List.generate(cols, (_) => 0),
  );

  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    // 초기 패턴 설정 (옵션)
    // 예: 글라이더
    /*
    board[1][2] = 1;
    board[2][3] = 1;
    board[3][1] = 1;
    board[3][2] = 1;
    board[3][3] = 1;
    */
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startGame() {
    if (isRunning) return;
    isRunning = true;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        board = nextGeneration(board);
      });
    });
  }

  void stopGame() {
    timer?.cancel();
    isRunning = false;
  }

  void resetGame() {
    stopGame();
    setState(() {
      board = List.generate(
        rows,
        (_) => List.generate(cols, (_) => 0),
      );
    });
  }

  List<List<int>> nextGeneration(List<List<int>> current) {
    List<List<int>> newBoard = List.generate(
      rows,
      (_) => List.generate(cols, (_) => 0),
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int liveNeighbors = countLiveNeighbors(current, i, j);
        if (current[i][j] == 1) {
          if (liveNeighbors == 2 || liveNeighbors == 3) {
            newBoard[i][j] = 1; // 살아남음
          } else {
            newBoard[i][j] = 0; // 죽음
          }
        } else {
          if (liveNeighbors == 3) {
            newBoard[i][j] = 1; // 번식
          }
        }
      }
    }

    return newBoard;
  }

  int countLiveNeighbors(List<List<int>> board, int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue; // 자기 자신은 제외
        int newRow = row + i;
        int newCol = col + j;
        if (newRow >= 0 &&
            newRow < rows &&
            newCol >= 0 &&
            newCol < cols &&
            board[newRow][newCol] == 1) {
          count++;
        }
      }
    }
    return count;
  }

  void toggleCell(int row, int col) {
    setState(() {
      board[row][col] = board[row][col] == 1 ? 0 : 1;
    });
  }

  Widget buildGrid() {
    return GestureDetector(
      onTapUp: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localPosition = box.globalToLocal(details.globalPosition);
        int col = (localPosition.dx / cellSize).floor();
        int row = (localPosition.dy / cellSize).floor();
        if (row >= 0 && row < rows && col >= 0 && col < cols) {
          toggleCell(row, col);
        }
      },
      child: CustomPaint(
        size: const Size(cols * cellSize, rows * cellSize),
        painter: GamePainter(board, cellSize),
      ),
    );
  }

  Widget buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: isRunning ? null : startGame,
          child: const Text('시작'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isRunning ? stopGame : null,
          child: const Text('일시정지'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: resetGame,
          child: const Text('초기화'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Conway\'s Game of Life'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: buildGrid(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildControls(),
            const SizedBox(height: 10),
          ],
        ));
  }
}

class GamePainter extends CustomPainter {
  final List<List<int>> board;
  final double cellSize;

  GamePainter(this.board, this.cellSize);

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
