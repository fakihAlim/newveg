import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import 'onboarding_state.dart';

// ---------------------------------------------------------------------------
// TTM Question Model — designed to be replaceable with server-fetched data.
// ---------------------------------------------------------------------------

/// Represents a single TTM questionnaire item.
///
/// This model is intentionally decoupled from the UI so that questions can
/// later be fetched from a backend API and injected here without changing
/// the screen code.
class TtmQuestion {
  final String id;
  final String text;
  final List<TtmOption> options;

  const TtmQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  /// Factory for creating from a server JSON response (future use).
  factory TtmQuestion.fromJson(Map<String, dynamic> json) {
    return TtmQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List)
          .map((o) => TtmOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single selectable option within a TTM question.
class TtmOption {
  final String label;
  final int score;

  const TtmOption({required this.label, required this.score});

  factory TtmOption.fromJson(Map<String, dynamic> json) {
    return TtmOption(
      label: json['label'] as String,
      score: json['score'] as int,
    );
  }
}

// ---------------------------------------------------------------------------
// Default local questions — will be replaced by server data in production.
// ---------------------------------------------------------------------------

/// Default TTM questions in Bahasa Indonesia.
/// These serve as fallback when the device is offline or the server has not
/// yet provided custom questions.
final List<TtmQuestion> defaultTtmQuestions = [
  const TtmQuestion(
    id: 'q1',
    text: 'Seberapa besar niat Anda untuk mulai mengonsumsi makanan berbasis nabati secara rutin?',
    options: [
      TtmOption(label: 'Belum terpikirkan sama sekali', score: 1),
      TtmOption(label: 'Baru mulai memikirkannya', score: 2),
      TtmOption(label: 'Sedang mempersiapkan rencana', score: 3),
      TtmOption(label: 'Sudah mulai menjalankan', score: 4),
      TtmOption(label: 'Sudah rutin > 6 bulan', score: 5),
    ],
  ),
  const TtmQuestion(
    id: 'q2',
    text: 'Seberapa sering Anda mengonsumsi sayuran dan buah-buahan dalam seminggu terakhir?',
    options: [
      TtmOption(label: 'Hampir tidak pernah', score: 1),
      TtmOption(label: '1-2 kali seminggu', score: 2),
      TtmOption(label: '3-4 kali seminggu', score: 3),
      TtmOption(label: 'Hampir setiap hari', score: 4),
      TtmOption(label: 'Setiap hari, setiap kali makan', score: 5),
    ],
  ),
  const TtmQuestion(
    id: 'q3',
    text: 'Apakah Anda sudah pernah mencoba mengurangi konsumsi daging atau produk hewani?',
    options: [
      TtmOption(label: 'Belum pernah dan belum berencana', score: 1),
      TtmOption(label: 'Belum pernah tapi mulai tertarik', score: 2),
      TtmOption(label: 'Sudah pernah mencoba beberapa kali', score: 3),
      TtmOption(label: 'Sedang mengurangi secara aktif', score: 4),
      TtmOption(label: 'Sudah berhenti sepenuhnya > 6 bulan', score: 5),
    ],
  ),
  const TtmQuestion(
    id: 'q4',
    text: 'Seberapa yakin Anda bahwa pola makan nabati bermanfaat bagi kesehatan Anda?',
    options: [
      TtmOption(label: 'Tidak yakin sama sekali', score: 1),
      TtmOption(label: 'Sedikit tertarik tapi ragu', score: 2),
      TtmOption(label: 'Cukup yakin akan manfaatnya', score: 3),
      TtmOption(label: 'Sangat yakin dan sudah merasakan', score: 4),
      TtmOption(label: 'Sepenuhnya yakin, sudah menjadi gaya hidup', score: 5),
    ],
  ),
  const TtmQuestion(
    id: 'q5',
    text: 'Bagaimana kesiapan Anda untuk berkomitmen pada pola makan berbasis nabati dalam 30 hari ke depan?',
    options: [
      TtmOption(label: 'Belum siap sama sekali', score: 1),
      TtmOption(label: 'Mungkin akan mencoba sedikit', score: 2),
      TtmOption(label: 'Siap mencoba dengan panduan', score: 3),
      TtmOption(label: 'Sangat siap dan sudah mulai', score: 4),
      TtmOption(label: 'Sudah menjalankan dan akan terus berlanjut', score: 5),
    ],
  ),
];

// ---------------------------------------------------------------------------
// TTM Scoring
// ---------------------------------------------------------------------------

/// Maps a total score (from 5 questions × 1‒5 scale) to a TTM stage.
///
/// Score ranges:
///   5–9   → Precontemplation
///   10–13 → Contemplation
///   14–17 → Preparation
///   18–21 → Action
///   22–25 → Maintenance
String determineTtmStage(int totalScore) {
  if (totalScore <= 9) return 'Precontemplation';
  if (totalScore <= 13) return 'Contemplation';
  if (totalScore <= 17) return 'Preparation';
  if (totalScore <= 21) return 'Action';
  return 'Maintenance';
}

// ---------------------------------------------------------------------------
// Onboarding StateNotifier
// ---------------------------------------------------------------------------

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final AppDatabase _db;

  OnboardingNotifier(this._db) : super(const OnboardingState());

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setAge(int age) {
    state = state.copyWith(age: age);
  }

  void setHeight(double height) {
    state = state.copyWith(height: height);
  }

  void setWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void setAvatar(String avatarPath) {
    state = state.copyWith(avatarPath: avatarPath);
  }

  void setDietPreference(String preference) {
    state = state.copyWith(dietPreference: preference);
  }

  void setTtmStage(String stage) {
    state = state.copyWith(ttmStage: stage);
  }

  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  /// Writes the accumulated onboarding data into the local SQLite database.
  /// Updates the existing row created during registration, or inserts a fallback.
  Future<void> saveProfile() async {
    final existingProfile = await _db.getUserProfile();
    final profile = UserProfilesCompanion(
      gender: Value(state.gender),
      age: Value(state.age),
      height: Value(state.height),
      weight: Value(state.weight),
      avatarPath: Value(state.avatarPath),
      dietPreference: Value(state.dietPreference),
      ttmStage: Value(state.ttmStage),
      dailyScanCount: const Value(0),
      lastScanDate: const Value(''),
    );

    if (existingProfile != null) {
      await _db.updateUserProfile(existingProfile.id, profile);
    } else {
      await _db.insertUserProfile(profile);
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// Provider for the [OnboardingNotifier] and its [OnboardingState].
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final db = ref.watch(databaseProvider);
  return OnboardingNotifier(db);
});

/// Provider exposing the TTM questions list.
/// In a future module, this can be swapped to fetch from a remote API.
final ttmQuestionsProvider = Provider<List<TtmQuestion>>((ref) {
  // TODO: Replace with server-fetched questions when backend is available.
  // e.g. ref.watch(remoteTtmQuestionsProvider).when(...)
  return defaultTtmQuestions;
});
