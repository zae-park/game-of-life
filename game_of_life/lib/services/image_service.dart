// lib/services/image_service.dart

import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageService {
// 이미지 저장
  Future<String> saveImage(img.Image image, String filename) async {
    final path = await getApplicationDocumentsDirectory();
    final file = File('${path.path}/$filename.png');
    List<int> pngBytes = img.encodePng(image);
    await file.writeAsBytes(pngBytes);
    return file.path;
  }

  // 이미지 로드
  Future<img.Image?> loadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;
      List<int> bytes = await file.readAsBytes();
      return img.decodeImage(bytes);
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  Future<img.Image> cannyEdgeFilter(
      img.Image image, double lowThreshold, double highThreshold) async {
    // 실제 Canny Edge Filter는 복잡하므로, 여기서는 Sobel 필터를 사용한 엣지 검출을 예시로 합니다.
    img.Image grayscale = img.grayscale(image);

    // Sobel 필터 적용
    img.Image sobel = img.sobel(grayscale);

    // 이진화 (Thresholding)
    img.Image binary = img.Image.from(grayscale);
    for (int y = 0; y < sobel.height; y++) {
      for (int x = 0; x < sobel.width; x++) {
        int pixel = sobel.getPixel(x, y);
        int brightness = img.getLuminance(pixel);
        if (brightness > highThreshold) {
          binary.setPixel(x, y, img.getColor(255, 255, 255));
        } else {
          binary.setPixel(x, y, img.getColor(0, 0, 0));
        }
      }
    }

    return binary;
  }

  List<List<int>> extractPatternFromEdges(img.Image edges,
      {required int rows, required int cols}) {
    List<List<int>> pattern =
        List.generate(rows, (_) => List.generate(cols, (_) => 0));

    int cellWidth = (edges.width / cols).floor();
    int cellHeight = (edges.height / rows).floor();

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int livePixels = 0;
        int totalPixels = cellWidth * cellHeight;
        for (int y = i * cellHeight; y < (i + 1) * cellHeight; y++) {
          for (int x = j * cellWidth; x < (j + 1) * cellWidth; x++) {
            if (x < edges.width && y < edges.height) {
              int pixel = edges.getPixel(x, y);
              int brightness = img.getLuminance(pixel);
              if (brightness > 128) livePixels++;
            }
          }
        }
        // 셀 내 live 픽셀 비율이 50% 이상이면 live cell로 간주
        pattern[i][j] = (livePixels / totalPixels) > 0.5 ? 1 : 0;
      }
    }

    return pattern;
  }
}
