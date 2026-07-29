import 'dart:io';

import 'package:newveg/core/services/gemini_vision_service.dart';

/// Immutable state for the food logging flow.
///
/// Tracks the current image, meal type selection, AI analysis progress,
/// and the analysis result.
class FoodLogState {
  final File? imageFile;
  final String? mealType;
  final FoodAnalysisResult? analysisResult;
  final bool isAnalyzing;
  final bool isSaving;
  final String? error;

  const FoodLogState({
    this.imageFile,
    this.mealType,
    this.analysisResult,
    this.isAnalyzing = false,
    this.isSaving = false,
    this.error,
  });

  FoodLogState copyWith({
    File? imageFile,
    String? mealType,
    FoodAnalysisResult? analysisResult,
    bool? isAnalyzing,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool clearResult = false,
    bool clearImage = false,
  }) {
    return FoodLogState(
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      mealType: mealType ?? this.mealType,
      analysisResult:
          clearResult ? null : (analysisResult ?? this.analysisResult),
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Whether the form is ready for AI analysis.
  bool get canAnalyze =>
      imageFile != null && mealType != null && !isAnalyzing;

  /// Whether the log can be saved (analysis must be completed).
  bool get canSave =>
      analysisResult != null && !isSaving && !isAnalyzing;
}
