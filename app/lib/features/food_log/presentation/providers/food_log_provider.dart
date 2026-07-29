import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/gemini_vision_service.dart';
import 'package:newveg/features/food_log/data/food_analysis_service.dart';
import 'food_log_state.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Maximum AI scans per day for free-tier users.
const int kFreeTierDailyLimit = 3;

/// Points awarded for plant-based compliant food.
const int kCompliantPoints = 50;

/// Points deducted for non-compliant food.
const int kNonCompliantPoints = -20;

// ---------------------------------------------------------------------------
// FoodLog StateNotifier
// ---------------------------------------------------------------------------

class FoodLogNotifier extends StateNotifier<FoodLogState> {
  final AppDatabase _db;
  final FoodAnalysisService _analysisService;

  FoodLogNotifier(this._db, this._analysisService) : super(const FoodLogState());

  void setImage(File image) {
    state = state.copyWith(
      imageFile: image,
      clearResult: true,
      clearError: true,
    );
  }

  void clearImage() {
    state = state.copyWith(clearImage: true, clearResult: true);
  }

  void setMealType(String mealType) {
    state = state.copyWith(mealType: mealType, clearError: true);
  }

  /// Sends the selected image to the remote backend for nutritional analysis.
  ///
  /// Enforces the daily scan limit for free-tier users before making the API call.
  Future<void> analyzeFood() async {
    if (!state.canAnalyze) return;

    state = state.copyWith(isAnalyzing: true, clearError: true, clearResult: true);

    try {
      // Check scan limit
      final profile = await _db.getUserProfile();
      if (profile == null) throw Exception('Profil tidak ditemukan.');

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final currentCount = await _db.resetDailyScanIfNeeded(profile.id, today);

      if (!profile.isPremium && currentCount >= kFreeTierDailyLimit) {
        throw Exception(
          'Batas scan harian tercapai ($kFreeTierDailyLimit/hari). '
          'Upgrade ke Premium untuk scan tanpa batas!',
        );
      }

      // Call Rotated API key remote analysis endpoint
      final result = await _analysisService.uploadAndAnalyze(
        imageFile: state.imageFile!,
        authToken: profile.authToken,
      );

      // Increment scan counter
      await _db.incrementDailyScanCount(profile.id, today);

      state = state.copyWith(analysisResult: result, isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Saves the analyzed food log to SQLite and updates user points.
  ///
  /// Returns the points earned/deducted.
  Future<int> saveFoodLog() async {
    if (!state.canSave) return 0;

    state = state.copyWith(isSaving: true);

    try {
      final result = state.analysisResult!;
      final points = result.isCompliant ? kCompliantPoints : kNonCompliantPoints;

      final log = FoodLogsCompanion(
        foodName: Value(result.foodName),
        imagePath: Value(state.imageFile!.path),
        calories: Value(result.calories),
        carbs: Value(result.carbs),
        fats: Value(result.fats),
        protein: Value(result.protein),
        isPlantBased: Value(result.isCompliant),
        pointsEarned: Value(points),
        mealType: Value(state.mealType!),
        createdAt: Value(DateTime.now()),
        isSynced: const Value(false),
      );

      await _db.insertFoodLog(log);

      // Update user points
      final profile = await _db.getUserProfile();
      if (profile != null) {
        await _db.addPoints(profile.id, points);
      }

      state = state.copyWith(isSaving: false);
      return points;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Gagal menyimpan log: $e',
      );
      return 0;
    }
  }

  /// Resets the state for a new food log entry.
  void reset() {
    state = const FoodLogState();
  }
}

/// Remote food analysis upload service provider.
final foodAnalysisServiceProvider = Provider<FoodAnalysisService>((ref) {
  return FoodAnalysisService();
});

/// Provider for the food log flow state and actions.
final foodLogProvider =
    StateNotifierProvider<FoodLogNotifier, FoodLogState>((ref) {
  final db = ref.watch(databaseProvider);
  final analysisService = ref.watch(foodAnalysisServiceProvider);
  return FoodLogNotifier(db, analysisService);
});

/// Provider that fetches today's food logs from the database.
final todayFoodLogsProvider = FutureProvider<List<FoodLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getTodayFoodLogs();
});
