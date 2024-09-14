// lib/pages/game_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/pattern_service.dart';
import '../models/canvas_template.dart';
import '../widgets/grid_painter.dart';
import '../widgets/control_panel.dart';
import '../widgets/toolbar.dart';
import 'image_processing_page.dart';

enum Mode { cell, draw }

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

  Mode currentMode = Mode.cell;
  bool isEraser = false;

  final GlobalKey _paintKey = GlobalKey();
  final PatternService patternService = PatternService();

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
        board = GameService.nextGeneration(board, rows, cols);
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

  void switchMode(Mode mode) {
    setState(() {
      currentMode = mode;
    });
  }

  void toggleEraser(bool value) {
    setState(() {
      isEraser = value;
    });
  }

  void toggleCell(int row, int col) {
    setState(() {
      board[row][col] = board[row][col] == 1 ? 0 : 1;
    });
  }

  void handleDraw(Offset localPosition) {
    int col = (localPosition.dx / cellSize).floor();
    int row = (localPosition.dy / cellSize).floor();
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      setState(() {
        board[row][col] = isEraser ? 0 : 1;
      });
    }
  }

  void navigateToImageProcessing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageProcessingPage(
          onProcessed: (pattern, imagePath) {
            setState(() {
              board = pattern;
            });
            // 패턴 저장 시 imagePath 포함
            saveCurrentPattern(imagePath);
          },
        ),
      ),
    );
  }

  // 패턴 저장 메서드 (이미지 경로는 선택적)
  void saveCurrentPattern([String imagePath = '']) async {
    List<Point> liveCells = [];
    List<Point> deadCells = [];
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (board[i][j] == 1) {
          liveCells.add(Point(x: j, y: i));
        } else {
          deadCells.add(Point(x: j, y: i));
        }
      }
    }

    // 셀 상태 비율 계산
    int liveCount = liveCells.length;
    int deadCount = rows * cols - liveCount;
    bool isSparse = liveCount < deadCount;

    // CanvasTemplate 생성
    CanvasTemplate template = CanvasTemplate(
      imagePath: imagePath,
      cells: isSparse ? liveCells : deadCells,
      isSparse: isSparse,
    );

    // 다이얼로그를 통해 파일 이름 입력 받기
    String? filename = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('패턴 저장'),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: "파일 이름"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    if (filename != null && filename.isNotEmpty) {
      await patternService.savePattern(template, filename);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('패턴이 저장되었습니다.')),
      );
    }
  }

  // 패턴 로드 메서드
  void loadPattern() async {
    List<String> patterns = await patternService.listPatterns();
    if (patterns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 패턴이 없습니다.')),
      );
      return;
    }

    String? selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('패턴 선택'),
          children: patterns.map((filename) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, filename),
              child: Text(filename),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      CanvasTemplate? template = await patternService.loadPattern(selected);
      if (template != null) {
        setState(() {
          board = List.generate(rows, (_) => List.generate(cols, (_) => 0));
          if (template.isSparse) {
            for (var point in template.cells) {
              if (point.y >= 0 &&
                  point.y < rows &&
                  point.x >= 0 &&
                  point.x < cols) {
                board[point.y][point.x] = 1;
              }
            }
          } else {
            // 전체 보드를 live으로 초기화하고, dead 셀을 설정
            board = List.generate(rows, (_) => List.generate(cols, (_) => 1));
            for (var point in template.cells) {
              if (point.y >= 0 &&
                  point.x >= 0 &&
                  point.y < rows &&
                  point.x < cols) {
                board[point.y][point.x] = 0;
              }
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('패턴이 로드되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conway\'s Game of Life'),
      ),
      body: Column(
        children: [
          Toolbar(
            currentMode: currentMode,
            isEraser: isEraser,
            onSwitchMode: switchMode,
            onToggleEraser: toggleEraser,
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanUpdate: (details) {
                  RenderBox? box = _paintKey.currentContext?.findRenderObject()
                      as RenderBox?;
                  if (box != null) {
                    Offset localPosition =
                        box.globalToLocal(details.globalPosition);
                    int col = (localPosition.dx / cellSize).floor();
                    int row = (localPosition.dy / cellSize).floor();
                    if (row >= 0 && row < rows && col >= 0 && col < cols) {
                      if (currentMode == Mode.cell) {
                        toggleCell(row, col);
                      } else if (currentMode == Mode.draw) {
                        handleDraw(localPosition);
                      }
                    }
                  }
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: CustomPaint(
                      key: _paintKey,
                      size: const Size(cols * cellSize, rows * cellSize),
                      painter: GridPainter(board, cellSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ControlPanel(
            onStart: startGame,
            onStop: stopGame,
            onReset: resetGame,
            onSave: () => saveCurrentPattern(),
            onLoad: loadPattern,
            onLoadImage: navigateToImageProcessing,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
