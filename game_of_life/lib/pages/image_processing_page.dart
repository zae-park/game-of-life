// lib/pages/image_processing_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

class ImageProcessingPage extends StatefulWidget {
  final Function(List<List<int>>) onProcessed;

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

    // Canny Edge Filter 적용 (간단한 엣지 검출 예시)
    img.Image edges = await imageService.cannyEdgeFilter(
        grayscale, lowThreshold, highThreshold);

    // 엣지 이미지에서 셀 패턴 추출
    List<List<int>> pattern =
        imageService.extractPatternFromEdges(edges, rows: 50, cols: 50);

    setState(() {
      isProcessing = false;
    });

    widget.onProcessed(pattern);
    Navigator.pop(context);
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
                  if (_imageFile != null) Image.file(_imageFile!),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text('이미지 선택'),
                  ),
                  const SizedBox(height: 10),
                  if (_imageFile != null) ...[
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
                    ElevatedButton(
                      onPressed: processImage,
                      child: const Text('엣지 검출 및 패턴 적용'),
                    ),
                  ],
                ],
              ));
  }
}
