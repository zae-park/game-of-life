// lib/services/pattern_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/canvas_template.dart';
import 'package:flutter/foundation.dart';

class PatternService {
  // 애플리케이션 문서 디렉토리 경로 가져오기
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 지정된 파일 이름의 JSON 파일 경로 가져오기
  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename.json');
  }

  // 지정된 파일 이름의 이미지 파일 경로 가져오기
  Future<File> _localImageFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename.png');
  }

  // 패턴 저장
  Future<void> savePattern(CanvasTemplate template, String filename) async {
    // JSON 파일 저장
    final jsonFile = await _localFile(filename);
    String jsonString = jsonEncode(template.toJson());
    await jsonFile.writeAsString(jsonString);

    // 이미지 파일이 있는 경우 저장
    if (template.imagePath.isNotEmpty) {
      final imageFile = File(template.imagePath);
      if (await imageFile.exists()) {
        final savedImageFile = await _localImageFile(filename);
        await imageFile.copy(savedImageFile.path);
      }
    }
  }

  // 패턴 로드
  Future<CanvasTemplate?> loadPattern(String filename) async {
    try {
      final jsonFile = await _localFile(filename);
      if (!await jsonFile.exists()) return null;

      String jsonString = await jsonFile.readAsString();
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // 이미지 경로 업데이트 (저장된 이미지 파일 경로로 변경)
      String savedImagePath = '';
      if (jsonMap['imagePath'] != null &&
          (jsonMap['imagePath'] as String).isNotEmpty) {
        final imageFile = await _localImageFile(filename);
        if (await imageFile.exists()) {
          savedImagePath = imageFile.path;
        }
      }

      CanvasTemplate template = CanvasTemplate(
        imagePath: savedImagePath,
        cells:
            (jsonMap['cells'] as List).map((e) => Point.fromJson(e)).toList(),
        isSparse: jsonMap['isSparse'],
      );

      return template;
    } catch (e) {
      print('Error loading pattern: $e');
      return null;
    }
  }

  // 저장된 모든 패턴 목록 가져오기
  Future<List<String>> listPatterns() async {
    final path = await _localPath;
    final directory = Directory(path);
    List<String> filenames = [];

    await for (var entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        filenames.add(entity.path.split('/').last.replaceAll('.json', ''));
      }
    }

    return filenames;
  }

  // 패턴 삭제 (옵션)
  Future<void> deletePattern(String filename) async {
    final jsonFile = await _localFile(filename);
    if (await jsonFile.exists()) {
      await jsonFile.delete();
    }

    final imageFile = await _localImageFile(filename);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
  }
}
