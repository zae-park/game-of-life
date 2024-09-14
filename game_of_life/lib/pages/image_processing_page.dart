// lib/pages/image_processing_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

class ImageProcessingPage extends StatefulWidget {
  final Function(List<List<int>>, String) onProcessed;

  const ImageProcessingPage({super.key, required this.onProcessed});

  @override
  _ImageProcessingPageState createState() => _ImageProcessingPageState();
}

class _ImageProcessingPageState extends State<ImageProcessingPage> {
  File? _imageFile;
  double lowThreshold = 50.0;
  double highThreshold = 150.0;
  bool isProcessing = false;

  final ImageService imageService = ImageService();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> processImage() async {
    if (_imageFile == null) return;

    setState(() {
      isProcessing = true;
    });

    img.Image? image = img.decodeImage(_imageFile!.readAsBytesSync());
    if (image == null) {
      setState(() {
        isProcessing = false;
      });
      return;
    }

    // 그레이스케일 변환
    img.Image grayscale = img.grayscale(image);

    // Canny Edge Filter 적용 (간단한 Sobel 필터 예시)
    img.Image edges = img.sobel(grayscale);

    // 이진화 (Thresholding)
    img.Image binary = img.Image.from(grayscale);
    for (int y = 0; y < edges.height; y++) {
      for (int x = 0; x < edges.width; x++) {
        int pixel = edges.getPixel(x, y);
        int brightness = img.getLuminance(pixel);
        if (brightness > highThreshold) {
          binary.setPixel(x, y, img.getColor(255, 255, 255));
        } else {
          binary.setPixel(x, y, img.getColor(0, 0, 0));
        }
      }
    }

    // 이미지 저장
    String savedImagePath =
        await imageService.saveImage(binary, 'processed_image');

    // 셀 패턴 추출
    List<List<int>> pattern =
        extractPatternFromEdges(binary, rows: 50, cols: 50);

    setState(() {
      isProcessing = false;
    });

    widget.onProcessed(pattern, savedImagePath);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 처리'),
      ),
      body: isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_imageFile != null)
                  Expanded(
                    child: Image.file(_imageFile!),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('이미지 선택'),
                ),
                const SizedBox(height: 10),
                if (_imageFile != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text('Low Threshold: ${lowThreshold.toInt()}'),
                        Slider(
                          value: lowThreshold,
                          min: 0,
                          max: 255,
                          divisions: 255,
                          label: lowThreshold.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              lowThreshold = value;
                            });
                          },
                        ),
                        Text('High Threshold: ${highThreshold.toInt()}'),
                        Slider(
                          value: highThreshold,
                          min: 0,
                          max: 255,
                          divisions: 255,
                          label: highThreshold.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              highThreshold = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: processImage,
                          child: const Text('엣지 검출 및 패턴 적용'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
