/// Immutable state class holding all onboarding form data across the 4-step flow.
///
/// Data is accumulated step-by-step and written to SQLite only upon final submission.
class OnboardingState {
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? avatarPath;
  final String? dietPreference;
  final String? ttmStage;
  final int currentStep;

  const OnboardingState({
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.avatarPath,
    this.dietPreference,
    this.ttmStage,
    this.currentStep = 0,
  });

  OnboardingState copyWith({
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? avatarPath,
    String? dietPreference,
    String? ttmStage,
    int? currentStep,
  }) {
    return OnboardingState(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      avatarPath: avatarPath ?? this.avatarPath,
      dietPreference: dietPreference ?? this.dietPreference,
      ttmStage: ttmStage ?? this.ttmStage,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Whether the profile step (Step 1) has all required fields filled.
  bool get isProfileComplete =>
      gender != null && age != null && height != null && weight != null;

  /// Whether an avatar has been selected (Step 2).
  bool get isAvatarSelected => avatarPath != null;

  /// Whether a diet preference has been chosen (Step 3).
  bool get isDietSelected => dietPreference != null;

  /// Whether the TTM stage has been determined (Step 4).
  bool get isTtmDetermined => ttmStage != null;

  /// Whether the full onboarding is complete and ready to save.
  bool get isComplete =>
      isProfileComplete && isAvatarSelected && isDietSelected && isTtmDetermined;
}
