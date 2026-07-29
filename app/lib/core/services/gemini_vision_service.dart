import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Result model returned by Gemini AI food analysis.
class FoodAnalysisResult {
  final String foodName;
  final double calories;
  final double carbs;
  final double fats;
  final double protein;
  final bool isCompliant;

  const FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.protein,
    required this.isCompliant,
  });

  /// Parse from Gemini's JSON response.
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['foodName'] as String? ?? 'Makanan Tidak Dikenali',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      isCompliant: json['isCompliant'] as bool? ?? false,
    );
  }
}

/// Service that sends food images to Gemini 2.5 Flash for nutritional analysis.
///
/// The API key is read from the `.env` file. In production, the key will be
/// fetched from the server. The model name is also configurable via `.env`.
class GeminiVisionService {
  GenerativeModel? _model;

  GenerativeModel get model {
    if (_model != null) return _model!;

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception(
        'Gemini API key belum dikonfigurasi. '
        'Silakan masukkan API key di file .env',
      );
    }

    final modelName = dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3,
      ),
    );
    return _model!;
  }

  /// Analyzes a food image using Gemini Vision API.
  ///
  /// [imageFile] — The captured/selected food photo.
  /// [dietPreference] — User's diet type (e.g., 'Strict Vegan', 'Flexitarian')
  ///   used to determine compliance.
  ///
  /// Returns a [FoodAnalysisResult] with nutritional estimates and compliance.
  Future<FoodAnalysisResult> analyzeFood({
    required File imageFile,
    required String dietPreference,
  }) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final String mimeType = _getMimeType(imageFile.path);

    final prompt = _buildPrompt(dietPreference);

    final content = Content.multi([
      TextPart(prompt),
      DataPart(mimeType, imageBytes),
    ]);

    try {
      final response = await model.generateContent([content]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw Exception('Gemini tidak memberikan respons.');
      }

      // Parse JSON from response
      final jsonStr = _extractJson(text);
      final Map<String, dynamic> parsed = json.decode(jsonStr);
      return FoodAnalysisResult.fromJson(parsed);
    } on GenerativeAIException catch (e) {
      throw Exception('Gagal menganalisis makanan: ${e.message}');
    } catch (e) {
      throw Exception('Kesalahan analisis AI: $e');
    }
  }

  /// Builds the structured system prompt for Gemini.
  String _buildPrompt(String dietPreference) {
    final complianceRules = _getComplianceRules(dietPreference);

    return '''
Kamu adalah ahli gizi AI. Analisis foto makanan berikut dan berikan estimasi nutrisi.

PREFERENSI DIET PENGGUNA: $dietPreference

ATURAN KEPATUHAN:
$complianceRules

INSTRUKSI:
1. Identifikasi nama makanan dalam Bahasa Indonesia.
2. Estimasi kalori (kkal), karbohidrat (g), lemak (g), dan protein (g).
3. Evaluasi apakah makanan tersebut sesuai (compliant) dengan preferensi diet pengguna.
4. Kembalikan respons HANYA dalam format JSON berikut, tanpa teks tambahan:

{
  "foodName": "Nama Makanan",
  "calories": 0,
  "carbs": 0,
  "fats": 0,
  "protein": 0,
  "isCompliant": true
}
''';
  }

  /// Returns compliance rules based on user's diet preference.
  String _getComplianceRules(String dietPreference) {
    switch (dietPreference) {
      case 'Strict Vegan':
        return '- 100% nabati. Tidak boleh mengandung produk hewani apapun '
            '(daging, ikan, telur, susu, madu, gelatin).';
      case 'Lacto-Ovo Vegetarian':
        return '- Nabati + telur + produk susu DIPERBOLEHKAN.\n'
            '- Daging, ikan, dan seafood TIDAK DIPERBOLEHKAN.';
      case 'Ovo-Vegetarian':
        return '- Nabati + telur DIPERBOLEHKAN.\n'
            '- Daging, ikan, seafood, dan produk susu TIDAK DIPERBOLEHKAN.';
      case 'Flexitarian':
        return '- Sebagian besar nabati. Sedikit produk hewani masih DIPERBOLEHKAN.\n'
            '- Semua makanan dianggap compliant pada tahap transisi ini.';
      default:
        return '- Evaluasi berdasarkan prinsip umum pola makan nabati.';
    }
  }

  /// Determines MIME type from file extension.
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  /// Extracts JSON from a response that might contain markdown code fences.
  String _extractJson(String text) {
    // Remove markdown code fences if present
    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    return cleaned;
  }
}
