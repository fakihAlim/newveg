import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:newveg/core/services/gemini_vision_service.dart';

class FoodAnalysisService {
  final String _uploadUrl = 'https://yodi.my.id/veg/web/api/food/analyze.php';

  /**
   * Resizes and crops the source image to exactly 600x600 pixels (JPEG 80% quality)
   * to guarantee fast upload size (<100 KB).
   */
  Future<File> compressImage(File sourceFile) async {
    final bytes = await sourceFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    
    if (decoded == null) {
      throw Exception("Failed to decode uploaded food image.");
    }

    // Determine square dimensions (center crop)
    final int size = decoded.width < decoded.height ? decoded.width : decoded.height;
    final int x = (decoded.width - size) ~/ 2;
    final int y = (decoded.height - size) ~/ 2;

    final cropped = img.copyCrop(decoded, x: x, y: y, width: size, height: size);
    final resized = img.copyResize(cropped, width: 600, height: 600);
    
    // Encode to JPEG with 80% quality
    final compressedBytes = img.encodeJpg(resized, quality: 80);

    // Save to cache directory
    final tempDir = Directory.systemTemp;
    final compressedFile = File('${tempDir.path}/food_log_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await compressedFile.writeAsBytes(compressedBytes);
    
    return compressedFile;
  }

  /**
   * Uploads compressed food photo to the remote PHP AI endpoint and parses nutritional details
   */
  Future<FoodAnalysisResult> uploadAndAnalyze({
    required File imageFile,
    required String? authToken,
  }) async {
    // 1. Compress image to 600x600 px first
    final compressedFile = await compressImage(imageFile);

    // 2. Build multipart HTTP POST request
    final uri = Uri.parse(_uploadUrl);
    final request = http.MultipartRequest('POST', uri);
    
    if (authToken != null && authToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }

    // Attach image
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        compressedFile.path,
      ),
    );

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception("Upload failed with status code: ${response.statusCode}");
    }

    final Map<String, dynamic> responseJson = json.decode(response.body);
    if (responseJson['success'] == false) {
      throw Exception(responseJson['message'] ?? 'AI analysis server error');
    }

    final data = responseJson['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Empty nutritional payload returned from server");
    }

    // Convert keys 'isPlantBased' from server to FoodAnalysisResult format
    final isPlantBased = data['isPlantBased'] as bool? ?? false;
    
    final formattedData = {
      'foodName': data['foodName'] ?? 'Makanan Tidak Dikenali',
      'calories': data['calories'] ?? 0,
      'carbs': data['carbs'] ?? 0,
      'fats': data['fats'] ?? 0,
      'protein': data['protein'] ?? 0,
      'isCompliant': isPlantBased, // Map isPlantBased to compliant state
    };

    return FoodAnalysisResult.fromJson(formattedData);
  }
}
