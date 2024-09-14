// lib/models/canvas_template.dart

class CanvasTemplate {
  final String imagePath; // 이미지 파일 경로 (Draw Mode)
  final List<Point> cells; // Live 또는 Dead 셀의 좌표
  final bool isSparse; // true: live 셀만 저장, false: dead 셀만 저장

  CanvasTemplate({
    required this.imagePath,
    required this.cells,
    required this.isSparse,
  });

  // JSON으로 직렬화
  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'cells': cells.map((e) => e.toJson()).toList(),
        'isSparse': isSparse,
      };

  // JSON에서 역직렬화
  factory CanvasTemplate.fromJson(Map<String, dynamic> json) {
    return CanvasTemplate(
      imagePath: json['imagePath'],
      cells: (json['cells'] as List).map((e) => Point.fromJson(e)).toList(),
      isSparse: json['isSparse'],
    );
  }
}

class Point {
  final int x;
  final int y;

  Point({required this.x, required this.y});

  // JSON으로 직렬화
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };

  // JSON에서 역직렬화
  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      x: json['x'],
      y: json['y'],
    );
  }
}
