import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newveg/core/database/app_database.dart';
import 'package:newveg/core/database/database_provider.dart';
import 'package:newveg/features/auth/data/auth_api_service.dart';
import 'package:newveg/core/services/api_service.dart';

/// Representation of the Authentication States
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfile? profile;
  final String? token;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
    this.token,
  });

  bool get isAuthenticated => token != null && profile != null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserProfile? profile,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profile: profile ?? this.profile,
      token: token ?? this.token,
    );
  }
}

/// StateNotifier controlling the authentication operations and session persistence.
class AuthNotifier extends StateNotifier<AuthState> {
  final AppDatabase _db;
  final AuthApiService _api = AuthApiService();

  AuthNotifier(this._db) : super(const AuthState()) {
    checkActiveSession();
  }

  /// Checks SQLite database for existing user profile and auth token
  Future<void> checkActiveSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _db.getUserProfile();
      if (profile != null && profile.authToken != null && profile.authToken!.isNotEmpty) {
        state = AuthState(token: profile.authToken, profile: profile);
        apiService.setToken(profile.authToken);
      } else {
        state = const AuthState();
        apiService.setToken(null);
      }
    } catch (e) {
      state = AuthState(errorMessage: 'Gagal memuat sesi: $e');
    }
  }

  /// Sign In with Email and Password
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final response = await _api.login(email: email, password: password);

    if (response['success'] == true && response['token'] != null) {
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      try {
        // Clear old profile sessions
        await _db.deleteAllProfiles();

        // Convert backend user fields into local drift SQLite model
        final companion = UserProfilesCompanion.insert(
          email: Value(userData['email'] as String?),
          fullName: Value(userData['full_name'] as String?),
          authToken: Value(token),
          gender: Value(userData['gender'] as String?),
          age: Value(userData['age'] != null ? int.parse(userData['age'].toString()) : null),
          height: Value(userData['height'] != null ? double.parse(userData['height'].toString()) : null),
          weight: Value(userData['weight'] != null ? double.parse(userData['weight'].toString()) : null),
          dietPreference: Value(userData['diet_preference'] as String?),
          ttmStage: Value(userData['ttm_stage'] as String?),
          totalPoints: Value(userData['total_points'] != null ? int.parse(userData['total_points'].toString()) : 0),
          isPremium: Value(userData['is_premium'] == 1 || userData['is_premium'] == true),
        );

        await _db.insertUserProfile(companion);
        await checkActiveSession();
        return true;
      } catch (e) {
        state = AuthState(errorMessage: 'Gagal menyimpan sesi lokal: $e');
        return false;
      }
    } else {
      state = AuthState(errorMessage: response['message'] ?? 'Login gagal.');
      return false;
    }
  }

  /// Register new user account
  Future<bool> signUp(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true);
    final response = await _api.register(email: email, password: password, fullName: fullName);

    if (response['success'] == true && response['token'] != null) {
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      try {
        await _db.deleteAllProfiles();

        // Store registration response
        final companion = UserProfilesCompanion.insert(
          email: Value(userData['email'] as String?),
          fullName: Value(userData['full_name'] as String?),
          authToken: Value(token),
          gender: const Value(null),
          age: const Value(null),
          height: const Value(null),
          weight: const Value(null),
          dietPreference: const Value('Vegan'),
          ttmStage: const Value('Precontemplation'),
          totalPoints: const Value(0),
          isPremium: const Value(false),
        );

        await _db.insertUserProfile(companion);
        await checkActiveSession();
        return true;
      } catch (e) {
        state = AuthState(errorMessage: 'Gagal menyimpan sesi baru: $e');
        return false;
      }
    } else {
      state = AuthState(errorMessage: response['message'] ?? 'Pendaftaran gagal.');
      return false;
    }
  }

  /// Sign out and clear credentials
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _db.deleteAllProfiles();
      state = const AuthState();
    } catch (e) {
      state = AuthState(errorMessage: 'Gagal menghapus sesi: $e');
    }
  }
}

/// Provider exposing the [AuthNotifier] and auth states.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthNotifier(db);
});
