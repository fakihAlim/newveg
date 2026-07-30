class CarbonCalculator {
  /// Amount of CO2 in kg saved per plant-based meal instead of meat-based.
  static const double co2SavedPerMeal = 2.5;

  /// Calculate total daily CO2 saved based on today's plant-based meals.
  static double calculateDailySavings(int plantBasedMealsCount) {
    return plantBasedMealsCount * co2SavedPerMeal;
  }

  /// Calculates equivalent number of trees planted (assuming 1 tree ~ 5 kg CO2 impact analogy).
  static double calculateEquivalentTrees(double co2Saved) {
    return co2Saved / 5.0;
  }

  /// Calculates equivalent driving distance in km (assuming 1 km ~ 0.25 kg CO2 emission saved).
  static double calculateEquivalentDrivingKm(double co2Saved) {
    return co2Saved * 4.0;
  }
}
